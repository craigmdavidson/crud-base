class AutoController
  module Resourced
    extend ActiveSupport::Concern


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
end