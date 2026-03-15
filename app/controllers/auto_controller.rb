class AutoController < ApplicationController
  include AutoRouteable, Parameterizable, Resourced

  layout "auto"

  helper_method :resource, :resources, :permitted_attributes, :table_attributes

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

  def resource_params
    params.require(model.model_name.param_key).permit(permitted_attributes)
  end
end
