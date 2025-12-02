# frozen_string_literal: true

class Envelope < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64
  include Rails.application.routes.url_helpers

  has_one_base64_attached :doc
  has_one_base64_attached :signed_doc

  has_many :recipients, class_name: 'EnvelopeRecipient'

  # Generic method to set up document attachments
  def setup_document_attachment(attachment_name, file_path = nil)
    # Set default file paths based on attachment name
    default_paths = {
      doc: 'public/documents/doc.pdf',
      signed_doc: 'public/documents/signed_doc.pdf'
    }

    file_path ||= default_paths[attachment_name.to_sym]

    # Check if file_path starts with public/ and resolve to public directory
    actual_path = if file_path.start_with?('public/')
                    Rails.root.join(file_path)
                  else
                    file_path
                  end

    # Ensure the file exists
    raise "File does not exist: #{actual_path}" unless File.exist?(actual_path)

    # Extract the filename for the attachment
    filename = File.basename(actual_path)

    # Create an ActiveStorage blob from the file
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(actual_path),
      filename: filename,
      content_type: content_type_for_file(actual_path)
    )

    # Attach the blob to the specified attachment
    send(attachment_name).attach(blob)

    # Save the envelope to persist changes
    save!
  end

  # Method to reset the doc attachment with the default document
  def reset_doc_attachment
    setup_document_attachment(:doc, 'public/documents/doc.pdf')
  end

  # Method to reset the signed doc attachment with the default document
  def reset_signed_doc_attachment
    setup_document_attachment(:signed_doc, 'public/documents/doc.pdf')
  end

  def doc_url
    return unless doc.attached?

    rails_blob_path(doc, only_path: true, disposition: 'attachment')
  end

  def signed_doc_url
    return unless signed_doc.attached?

    rails_blob_path(signed_doc, only_path: true, disposition: 'attachment')
  end

  private

    # Determine content type based on file extension
    def content_type_for_file(file_path)
      case File.extname(file_path).downcase
      when '.pdf'
        'application/pdf'
      when '.doc'
        'application/msword'
      when '.docx'
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      when '.jpg', '.jpeg'
        'image/jpeg'
      when '.png'
        'image/png'
      when '.gif'
        'image/gif'
      else
        'application/octet-stream'
      end
    end
end
