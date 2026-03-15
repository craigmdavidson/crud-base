require "test_helper"

class MoneyParserTest < ActiveSupport::TestCase
  test "parses" do
    assert_equal Money.new(100_000, "USD"), Money::Parser.parse("100000")
    assert_equal Money.new(100_000, "USD"), Money::Parser.parse("100,000")
    assert_equal Money.new(100_000, "USD"), Money::Parser.parse("$100,000")
    assert_equal Money.new(100_000, "USD"), Money::Parser.parse("  $100,000  ")
    assert_equal Money.new(100_000, "GBP"), Money::Parser.parse("£100,000")
    assert_equal Money.new(50_000, "EUR"), Money::Parser.parse("€50,000")
    assert_equal Money.new(100_000, "AUD"), Money::Parser.parse("A$100,000")
    assert_equal Money.new(100_000, "NZD"), Money::Parser.parse("NZ$100,000")
    assert_equal Money.new(100_000, "AUD"), Money::Parser.parse("AUD 100,000")
    assert_equal Money.new(100_000, "CAD"), Money::Parser.parse("CAD100,000")
    assert_equal Money.new(100_000, "E"), Money::Parser.parse("E100,000")
    assert_equal Money.new(50_000, "CHF"), Money::Parser.parse("CHF 50,000")
    assert_equal Money.new(1_234.56, "USD"), Money::Parser.parse("$1,234.56")
    assert_equal Money.new(100, "GBP"), Money::Parser.parse(Money.new(100, "GBP"))
  end

  test "returns nil amount for blank input" do
    # TODO - this should return nil
    money = Money::Parser.parse("")
    assert_nil money.amount
  end

  test "returns nil amount for nil input" do
    # TODO - this should return nil
    money = Money::Parser.parse(nil)
    assert_nil money.amount
  end
end
