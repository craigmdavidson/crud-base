module HasCrudController
  extend ActiveSupport::Concern

  class_methods do
    def has_crud_controller(model: self, scope: nil, permit: nil, allow_unauthenticated: [], after_save_redirect_to: :show, sidebar: true, controller_name: nil)
      controller_name ||= "#{model.name.pluralize}Controller"

      controller_class = Class.new(CrudController) do
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
    end
  end
end
