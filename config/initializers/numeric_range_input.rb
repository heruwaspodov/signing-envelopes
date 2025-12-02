# frozen_string_literal: true

class NumericRangeInput < Formtastic::Inputs::StringInput
  # rubocop:disable Metrics/AbcSize
  def to_html
    template.content_tag(:div) do
      label_html +
        template.content_tag(:div) do
          builder.text_field("#{method}_gteq", input_html_options.merge(
                                                 placeholder: 'From',
                                                 class: 'form-control',
                                                 type: 'number'
                                               )) +
            template.content_tag(:div, style: 'margin-top: 10px;') do
              builder.text_field("#{method}_lteq", input_html_options.merge(
                                                     placeholder: 'To',
                                                     class: 'form-control',
                                                     type: 'number'
                                                   ))
            end
        end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def label_html_options
    super.merge(for: input_html_options[:id])
  end
end
