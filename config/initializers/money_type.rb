module MoneyColumn
  def money(name, precision: 10, scale: 2, **options)
    decimal :"#{name}_amount", precision: precision, scale: scale, **options
    string :"#{name}_currency", default: "USD"
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::ConnectionAdapters::TableDefinition.prepend(MoneyColumn)

  if defined?(ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition)
    ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.prepend(MoneyColumn)
  end
end
