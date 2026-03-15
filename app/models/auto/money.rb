module Auto
  class Money
    include Comparable

    CURRENCY_SYMBOLS = {
      "A$" => "AUD", "NZ$" => "NZD", "C$" => "CAD", "HK$" => "HKD", "S$" => "SGD",
      "$" => "USD", "£" => "GBP", "€" => "EUR", "¥" => "JPY", "₹" => "INR"
    }.freeze

    SYMBOLS_FOR_CURRENCY = CURRENCY_SYMBOLS.invert.freeze

    attr_reader :amount, :currency

    def initialize(amount, currency = "USD")
      @amount = amount
      @currency = currency
    end

    def self.parse(value)
      return value if value.is_a?(Money)
      return new(nil) if value.blank?

      str = value.to_s.strip
      currency = nil

      # Try known symbols, longest first so A$ matches before $
      CURRENCY_SYMBOLS.keys.sort_by { |s| -s.length }.each do |symbol|
        if str.start_with?(symbol)
          currency = CURRENCY_SYMBOLS[symbol]
          str = str.delete_prefix(symbol).strip
          break
        end
      end

      # Try a currency code prefix (e.g. "USD", "AUD", "E")
      if currency.nil? && str.match?(/\A[A-Za-z]{1,4}[\s\d]/)
        code = str[/\A[A-Za-z]+/]
        str = str.delete_prefix(code).strip
        currency = code.upcase
      end

      currency ||= "USD"

      new(BigDecimal(str.delete(",")), currency)
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
end
