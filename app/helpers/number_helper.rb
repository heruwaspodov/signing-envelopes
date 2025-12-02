# frozen_string_literal: true

module NumberHelper
  include ActiveSupport::NumberHelper
  def to_rupiah(value)
    if value.blank?
      '-'
    else
      number_to_currency value, unit: 'Rp. ', separator: ',', delimiter: '.', precision: 0
    end
  end
end
