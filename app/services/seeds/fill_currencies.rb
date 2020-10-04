# frozen_string_literal: true

class Seeds::FillCurrencies
  def self.perform_for(currencies)
    currencies.each do |currency|
      next if Currency.where(code: currency[:code]).exists?

      puts "currency: #{currency[:code]}"
      Currency.create! currency
    end
  end
end
