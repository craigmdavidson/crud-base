class Money::Parser
  def self.parse(value)
    new(value).parse
  end

  def initialize(value)
    @value = value
  end

  def parse
    return @value if @value.is_a?(Money)
    return Money.new(nil) if @value.blank?

    @str = @value.to_s.strip
    @currency = extract_symbol || extract_code || Money.default_currency

    Money.new(BigDecimal(@str.delete(",")), @currency)
  end

  private

  def extract_symbol
    Money::CURRENCY_SYMBOLS.keys.sort_by { |s| -s.length }.each do |symbol|
      if @str.start_with?(symbol)
        @str = @str.delete_prefix(symbol).strip
        return Money::CURRENCY_SYMBOLS[symbol]
      end
    end
    nil
  end

  def extract_code
    return unless @str.match?(/\A[A-Za-z]{1,4}[\s\d]/)

    code = @str[/\A[A-Za-z]+/]
    @str = @str.delete_prefix(code).strip
    code.upcase
  end
end
