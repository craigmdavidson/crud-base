module Auto
  class Fieldset
    include ActionView::Helpers::TagHelper

    attr_reader :form, :attribute, :model

    def initialize(form, attribute, model:)
      @form = form
      @attribute = attribute
      @model = model
    end

    def render
      content_tag(:fieldset, class: "fieldset") do
        legend + input
      end
    end

    private

    def legend
      content_tag(:legend, model.human_attribute_name(attribute), class: "fieldset-legend")
    end

    def column
      model.columns_hash[attribute.to_s]
    end

    def input
      case column&.type
      when :text     then form.text_area attribute, rows: 8, class: "textarea w-full"
      when :boolean  then form.check_box attribute, class: "checkbox checkbox-primary"
      when :integer, :float, :decimal then form.number_field attribute, class: "input w-full"
      when :date     then form.date_field attribute, class: "input w-full"
      when :datetime then form.datetime_local_field attribute, class: "input w-full"
      else form.text_field attribute, class: "input w-full"
      end
    end
  end
end
