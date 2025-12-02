# frozen_string_literal: true

unless Rails.env.test?
  WickedPdf.config ||= {}
  WickedPdf.config.merge!({
                            layout: 'pdf.html.erb',
                            page_size: 'A4'
                          })
end
