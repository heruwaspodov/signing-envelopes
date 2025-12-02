# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class EnvelopeRecipient < ApplicationRecord
  belongs_to :envelope

  before_save :format_annotations, if: :annotations_changed?

  SUPPORTED_MULTIPLE_SIGNATURE = %w[signature initial meterai stamp].freeze
  PARAMS_ANNOTATION = Struct.new(:signature, :initial, :certified_doc_signature, :stamp)
  STANDARD_ANNOTATION = %w[
    free_text date_text email_text phone_text currency_text radio checkbox number
  ].freeze
  SUPPORTED_ANNOTATION = %w[
    signature initial meterai stamp
    date_signed name email company job_title address
    free_text date_text email_text phone_text currency_text radio checkbox number
    qr_code certified_doc_signature
  ].freeze

  def format_annotations
    return unless annotations.is_a?(String)

    formatted = TextAsJson.json(annotations)
    self.annotations = JSON.parse(formatted)
  end

  def annotate_signature!(tempfile, image, annotation)
    img_annotation = Annotations::AnnotationSignature.new(
      tempfile, image, annotation['page']
    )
    img_annotation.recipient = self
    img_annotation.setup_dss(envelope.id)
    img_annotation.setup_attributes(annotation)
    img_annotation.process!
  end

  def annotate_image!(tempfile, image, annotation)
    img_annotation = Annotations::AnnotationImage.new(
      tempfile, image, annotation['page']
    )

    img_annotation.setup_attributes(annotation)
    img_annotation.process!
  end

  def bulk_annotate_images!(tempfile, image_params)
    Annotations::V2::AnnotationImage.call(
      tempfile, image_params, image_annotations
    )
  end

  def annotate_text!(tempfile, text, annotation)
    text_annotation = Annotations::AnnotationText.new(
      tempfile, text, annotation['page']
    )

    text_annotation.setup_attributes(annotation)
    text_annotation.process!
  end

  def bulk_annotate_texts!(tempfile)
    Annotations::V2::AnnotationText.call(
      tempfile, text_params, text_annotations
    )
  end

  def image_annotations
    return if annotations.blank?

    annotations.select do |annotation|
      Annotations::V2::AnnotationImage::SUPPORTED_ANNOTATION.include? annotation['type_of']
    end
  end

  def text_annotations
    return if annotations.blank?

    annotations.select do |annotation|
      Annotations::V2::AnnotationText::SUPPORTED_ANNOTATION.include? annotation['type_of']
    end
  end

  def text_params
    {
      date_signed: date_signed_formatted,
      email: email
    }
  end

  def date_signed_annotations
    text_annotations.select do |annotation|
      annotation['type_of'] == 'date_signed'
    end
  end

  def date_signed_formatted
    date_signed_annotations.empty? ? '' : setup_date_format(date_signed_annotations.first)
  end

  def annotate!(annotation_params, standard_annotation = {})
    return if without_annotation?

    if envelope.is_certified
      multiple_cert(annotation_params)
    else
      single_cert(annotation_params,
                  standard_annotation)
    end
  end

  def without_annotation?
    annotations.empty?
  end

  def without_document_attached?
    !document.attached?
  end

  def single_cert(annotation_params, standard_annotation)
    document.reload

    document.open do |tempfile|
      annotations.each do |field|
        next unless field['type_of']&.in?(SUPPORTED_ANNOTATION)

        annotate_by_type(tempfile, field)
        annotate_standard(tempfile, field, standard_annotation)
      end

      bulk_annotate_images!(tempfile, annotation_params)

      tempfile.rewind
      attach_signed_doc!(tempfile)
    end
  end

  def annotate_standard(tempfile, field, annotations)
    return unless field['type_of']&.in?(STANDARD_ANNOTATION)

    image = annotations[field['id']]
    return unless image.present?

    annotate_image!(tempfile, image, field)
  end

  def annotate_type_text(tempfile, field)
    case field['type_of']
    when 'name'
      annotate_text!(tempfile, name, field)
    when 'email'
      annotate_text!(tempfile, email, field)
    when 'company'
      annotate_text!(tempfile, meta['company_name'], field)
    when 'date_signed'
      annotate_text!(tempfile, setup_date_format(field), field)
    end
  end

  def annotate_type_text_value(tempfile, field)
    return unless field['value'].present? && %w[job_title address].include?(field['type_of'])

    annotate_text!(tempfile, field['value'], field)
  end

  def annotate_by_type(tempfile, field)
    annotate_type_text(tempfile, field)
    annotate_type_text_value(tempfile, field)
  end

  def annotate_type_multi_signature(tempfile, field, annotations)
    multiple_w_single_params(tempfile, field, annotations)
    multiple_w_array_params(tempfile, field, annotations)
  end

  def multiple_w_single_params(tempfile, field, annotations)
    case field['type_of']
    when 'signature'
      annotate_signature!(tempfile, annotations.signature, field) if annotations.signature
    when 'initial'
      annotate_signature!(tempfile, annotations.initial, field) if annotations.initial
    end
  end

  def build_signature_from_id(annotations, id)
    signature = annotations.find { |annot| annot['id'] == id }
    return unless signature.present?

    Files::FileValidation.new(signature['value']) if signature['value'].present?
  end

  def multiple_w_array_params(tempfile, field, annotations)
    return tempfile unless %w[signature initial].include? field['type_of']
    return tempfile unless annotations.certified_doc_signature.present?

    img_signature = build_signature_from_id(annotations.certified_doc_signature, field['id'])
    return tempfile unless img_signature.present?

    annotate_signature!(tempfile, img_signature.tempfile, field)
  end

  def multiple_cert(annotation_params)
    file = temp_doc

    annotations.each do |field|
      next unless field['type_of']&.in?(SUPPORTED_ANNOTATION)

      file = annotate_type_multi_signature(file, field, annotation_params)
    end

    file.rewind
    attach_signed_doc!(file)
  ensure
    temp_doc.close!
  end

  def temp_doc
    temp_doc = Tempfile.new([envelope.id, '.pdf'])
    temp_doc.binmode
    temp_doc.write(document.download)
    temp_doc.rewind
    temp_doc
  end

  def document
    return envelope.signed_doc if envelope.signed_doc.present?

    envelope.doc
  end

  # rubocop:disable Metrics/AbcSize
  def cert!
    return true unless Rails.env.staging? || Rails.env.production? || Rails.env.sandbox?

    document.reload
    success = false
    document.open do |tempfile|
      certificate = Certifications::Cert.new(tempfile, envelope.id)
      certificate.cert!
      success = certificate.success
      if success
        certificate.output_file.rewind
        attach_signed_doc!(certificate.output_file)
      end
      certificate.cleanup!
    end

    success
  end

  # rubocop:enable Metrics/AbcSize
  def no_signature?
    annotations.none? { |annotation| %w[signature].include?(annotation['type_of']) }
  end

  private

    def attach_signed_doc!(tempfile)
      FileUtils.cp(tempfile.path, "tmp/signed-#{envelope.filename}.pdf")

      process_attach_signed_doc(tempfile)
    end

    def process_attach_signed_doc(tempfile)
      signed = envelope.signed_doc
                       .attach({ filename: envelope.filename, io: tempfile })

      # signed.save unless signed.is_a?(ToBoolean) # NOTE: Need .save -> https://github.com/rails/rails/issues/43663
      signed.save if signed.respond_to?(:save)
    end
end
# rubocop:enable Metrics/ClassLength
