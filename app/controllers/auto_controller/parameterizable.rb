class AutoController
  module Parameterizable
    extend ActiveSupport::Concern

    included do
      @sidebar_controllers = []

      class_attribute :model, instance_writer: false
      class_attribute :scope, instance_writer: false
      class_attribute :permit, instance_writer: false, default: []
      class_attribute :after_save_redirect_to, instance_writer: false, default: :show
      class_attribute :key_attributes, instance_writer: false, default: []
    end

    class_methods do
      def allow_unauthenticated=(actions)
        allow_unauthenticated_access only: actions if actions.present?
      end

      def sidebar_controllers
        AutoController.instance_variable_get(:@sidebar_controllers)
      end

      def sidebar=(value)
        if value
          sidebar_controllers << self unless sidebar_controllers.include?(self)
        else
          sidebar_controllers.delete(self)
        end
      end
    end
    
    private
    
    def after_save_url
      case self.class.after_save_redirect_to
      when :index
        url_for(action: :index)
      when :parent
        polymorphic_path(parent_record, tab: model.model_name.route_key)
      else
        url_for(action: :show, id: resource)
      end
    end
    
    def permitted_attributes
      if permit
        permit
      else
        attrs = model.column_names.map(&:to_sym) - [:id, :created_at, :updated_at]
        belongs_to_keys = model.reflect_on_all_associations(:belongs_to).map { |a| a.foreign_key.to_sym }
        attrs | belongs_to_keys
      end
    end

    def table_attributes
      key_attributes.present? ? key_attributes : permitted_attributes
    end
  end
end
