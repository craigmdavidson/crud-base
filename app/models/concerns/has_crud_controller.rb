module HasCrudController
  extend ActiveSupport::Concern

  class_methods do
    def has_crud_controller(model: self, scope: nil, permit: [], allow_unauthenticated: [], after_save_redirect_to: :show, controller_name: nil)
      controller_name ||= "#{model.name.pluralize}Controller"

      controller_class = Class.new(CrudController) do
        self.model = model
        self.scope = scope
        self.permit = permit
        self.after_save_redirect_to = after_save_redirect_to
      end

      controller_class.allow_unauthenticated = allow_unauthenticated if allow_unauthenticated.present?

      Object.const_set(controller_name, controller_class)
    end
  end
end
