module HasMoney
  extend ActiveSupport::Concern

  class_methods do
    def money(*attributes)
      attributes.each do |attribute|
        composed_of attribute,
          class_name: "Auto::Money",
          mapping: [ [ "#{attribute}_amount", "amount" ], [ "#{attribute}_currency", "currency" ] ],
          allow_nil: true,
          converter: :parse
      end
    end
  end
end
