class CrudController < ApplicationController
  class_attribute :model, instance_writer: false
  class_attribute :scope, instance_writer: false
  class_attribute :permit, instance_writer: false, default: []
  class_attribute :after_save_redirect_to, instance_writer: false, default: :show
  @sidebar_controllers = []

  class << self
    def allow_unauthenticated=(actions)
      allow_unauthenticated_access only: actions if actions.present?
    end

    def sidebar_controllers
      CrudController.instance_variable_get(:@sidebar_controllers)
    end

    def sidebar=(value)
      if value
        sidebar_controllers << self unless sidebar_controllers.include?(self)
      else
        sidebar_controllers.delete(self)
      end
    end
  end

  helper_method :resource, :resources, :permitted_attributes

  def index
    self.resources = resource_scope.all
  end

  def show
    self.resource = resource_scope.find(params[:id])
  end

  def new
    self.resource = resource_scope.new
    render :inline_new, layout: false if params[:inline].present?
  end

  def create
    self.resource = resource_scope.new(resource_params)
    if resource.save
      if params[:inline].present?
        render :inline_created, layout: false
      else
        redirect_to after_save_url, notice: "#{model.model_name.human} was successfully created."
      end
    else
      if params[:inline].present?
        render :inline_new, layout: false, status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    self.resource = resource_scope.find(params[:id])
  end

  def update
    self.resource = resource_scope.find(params[:id])
    if resource.update(resource_params)
      redirect_to after_save_url, notice: "#{model.model_name.human} was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    self.resource = resource_scope.find(params[:id])
    resource.destroy!
    redirect_to url_for(action: :index), notice: "#{model.model_name.human} was successfully destroyed."
  end

  private

  def resource_scope
    return model.all unless scope

    result = instance_exec(&scope)
    case result
    when ActiveRecord::Relation
      result
    when ApplicationRecord
      result.public_send(model.model_name.plural)
    when Class
      parent_record ? parent_record.public_send(model.model_name.plural) : model.all
    else
      model.all
    end
  end

  def parent_record
    return unless scope

    result = instance_exec(&scope)
    return unless result.is_a?(Class) && result < ApplicationRecord

    parent_id = params[:"#{result.model_name.param_key}_id"]
    @parent_record ||= result.find(parent_id) if parent_id
  end

  def after_save_url
    case self.class.after_save_redirect_to
    when :index
      url_for(action: :index)
    when :parent
      parent_record
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

  def resource_params
    params.require(model.model_name.param_key).permit(permitted_attributes)
  end

  def resource
    instance_variable_get(:"@#{model.model_name.singular}")
  end

  def resource=(value)
    instance_variable_set(:"@#{model.model_name.singular}", value)
  end

  def resources
    instance_variable_get(:"@#{model.model_name.plural}")
  end

  def resources=(value)
    instance_variable_set(:"@#{model.model_name.plural}", value)
  end
end
