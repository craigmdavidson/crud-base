class Money
  include Comparable

  CURRENCY_SYMBOLS = {
    "A$" => "AUD", "NZ$" => "NZD", "C$" => "CAD", "HK$" => "HKD", "S$" => "SGD",
    "$" => "USD", "£" => "GBP", "€" => "EUR", "¥" => "JPY", "₹" => "INR"
  }.freeze

  SYMBOLS_FOR_CURRENCY = CURRENCY_SYMBOLS.invert.freeze

  class_attribute :default_currency, default: "USD"

  attr_reader :amount, :currency

  def initialize(amount, currency = self.class.default_currency)
    @amount = amount
    @currency = currency
  end

  def self.parse(value)
    Parser.parse(value)
  end

  def <=>(other)
    return nil unless other.is_a?(Money) && currency == other.currency

    amount <=> other.amount
  end

  def to_s
    return "" if amount.nil?

    symbol = SYMBOLS_FOR_CURRENCY[currency]
    prefix = symbol || "#{currency} "
    whole, decimal = amount.to_s("F").split(".")
    formatted = whole.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    formatted = "#{formatted}.#{decimal}" if decimal && decimal != "0"
    "#{prefix}#{formatted}"
  end
end
