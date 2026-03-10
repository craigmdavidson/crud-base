module HasAutoController
  extend ActiveSupport::Concern

  class_methods do
    def has_nested_auto_controllers(for_parents:, **options)
      for_parents.each { |parent_model| has_nested_auto_controller(parent_model, **options) }
    end

    def has_nested_auto_controller(parent_model, **options)
      options[:scope] ||= -> { parent_model }
      options[:controller_name] ||= "#{parent_model.name.pluralize}::#{name.pluralize}Controller"
      options[:after_save_redirect_to] ||= :parent

      parent_resource = parent_model.model_name.route_key.to_sym
      child_resource = model_name.route_key.to_sym
      mod = parent_resource

      AutoController.register_root_route(parent_resource)
      AutoController.register_nested_route(parent_resource, child_resource, mod)

      has_auto_controller(**options, sidebar: false, _skip_route_registration: true)
    end

    def has_auto_controller(model: self, scope: nil, permit: nil, allow_unauthenticated: [], after_save_redirect_to: :show, sidebar: true, controller_name: nil, _skip_route_registration: false)
      controller_name ||= "#{model.name.pluralize}Controller"

      controller_class = Class.new(AutoController) do
        self.model = model
        self.scope = scope
        self.permit = permit
        self.after_save_redirect_to = after_save_redirect_to
      end

      controller_class.allow_unauthenticated = allow_unauthenticated if allow_unauthenticated.present?
      controller_class.sidebar = sidebar

      parts = controller_name.split("::")
      namespace = parts[0..-2].reduce(Object) do |mod, name|
        mod.const_defined?(name) ? mod.const_get(name) : mod.const_set(name, Module.new)
      end
      namespace.const_set(parts.last, controller_class)

      unless _skip_route_registration
        AutoController.register_root_route(model.model_name.route_key.to_sym)
      end
    end
  end
end
