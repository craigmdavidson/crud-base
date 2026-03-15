module MoneyColumn
  def money_with_currency(name, precision: 10, scale: 2, **options)
    decimal :"#{name}_amount", precision: precision, scale: scale, **options
    string :"#{name}_currency", default: Money.default_currency
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::ConnectionAdapters::TableDefinition.prepend(MoneyColumn)
  ActiveRecord::ConnectionAdapters::Table.prepend(MoneyColumn)

  if defined?(ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition)
    ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.prepend(MoneyColumn)
  end
end
