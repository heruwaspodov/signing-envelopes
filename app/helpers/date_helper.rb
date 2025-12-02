# frozen_string_literal: true

module DateHelper
  def setup_date_format(field)
    date = DateTime.now + 7.hours
    case field['date_format']
    when 1
      I18n.l(date, formats: :default, locale: :id)
    when 2
      date.strftime('%d/%m/%Y')
    when 3
      date.strftime('%m/%d/%Y')
    else
      I18n.l(date, formats: :default, locale: :en)
    end
  end

  def app_date(date, format = '%Y-%m-%d %H:%M:%S')
    date&.strftime(format)
  end
end
