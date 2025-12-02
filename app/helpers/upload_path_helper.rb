# frozen_string_literal: true

module UploadPathHelper
  ATTACHMENT_NAME = %w[avatars company_logos attachments images initial_images identity_attachments
                       selfie_attachments docs signed_docs doc_thumbnails
                       passport_attachments employment_attachments].freeze
  def create_blob_from_base64(obj, file, attachment_name)
    return unless valid_base64?(file, attachment_name)

    model_name = obj.class.name.underscore
    random_key = ActiveStorage::Blob.generate_unique_secure_token
    date = Time.current.strftime('%Y-%m')
    custom_key = "#{model_name}_#{attachment_name}/#{date}/#{obj.id}/#{random_key}"
    split_base64 = file.split(',')
    decoded_data = decoded_data(split_base64.try(:last))
    content_type = content_type(split_base64.try(:first))

    create_blob_base64(decoded_data, content_type, custom_key, obj)
  end

  def create_blob_from_file(obj, file, attachment_name, filename)
    return unless ATTACHMENT_NAME.include?(attachment_name)

    model_name = obj.class.name.underscore
    random_key = ActiveStorage::Blob.generate_unique_secure_token
    date = Time.current.strftime('%Y-%m')
    custom_key = "#{model_name}_#{attachment_name}/#{date}/#{obj.id}/#{random_key}"

    ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: filename,
      content_type: 'application/pdf',
      key: custom_key
    )
  end

  def create_blob_from_image(obj, file, attachment_name, filename)
    return unless ATTACHMENT_NAME.include?(attachment_name)

    model_name = obj.class.name.underscore
    random_key = ActiveStorage::Blob.generate_unique_secure_token
    date = Time.current.strftime('%Y-%m')
    custom_key = "#{model_name}_#{attachment_name}/#{date}/#{obj.id}/#{random_key}"

    ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: filename,
      content_type: 'image/png',
      key: custom_key
    )
  end

  private

    def create_blob_base64(decoded_data, content_type, custom_key, obj)
      return unless decoded_data.present?

      filename = obj.instance_of?(Envelope) ? "#{obj.filename}.pdf" : Time.current.to_i.to_s
      content_type = 'application/pdf' if obj.instance_of?(Envelope)
      ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(decoded_data),
        filename: filename,
        content_type: content_type,
        key: custom_key
      )
    end

    def decoded_data(file)
      Base64.decode64(file)
    end

    def content_type(file)
      file.match(/\Adata:(.*?);/)[1]
    rescue StandardError
      nil
    end

    def valid_base64?(value, attachment_name)
      return false unless ATTACHMENT_NAME.include?(attachment_name)

      image = value.split(',')
      return unless image.present?

      image.last.is_a?(String) && Base64.strict_encode64(Base64.decode64(image.last)) == image.last
    end
end
