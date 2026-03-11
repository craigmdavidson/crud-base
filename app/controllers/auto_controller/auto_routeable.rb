class AutoController
  module AutoRouteable
    extend ActiveSupport::Concern
    
    included do
      @root_routes = []
      @nested_routes = Hash.new { |h, k| h[k] = [] }      
    end
    
    class_methods do
      def root_routes
        AutoController.instance_variable_get(:@root_routes)
      end

      def nested_routes
        AutoController.instance_variable_get(:@nested_routes)
      end

      def register_root_route(resource_name)
        root_routes << { name: resource_name } unless root_routes.any? { |r| r[:name] == resource_name }
      end

      def register_nested_route(parent_resource, child_resource, mod)
        children = nested_routes[parent_resource]
        children << { name: child_resource, module: mod } unless children.any? { |c| c[:name] == child_resource && c[:module] == mod }
      end

      def draw_routes(router)
        Rails.autoloaders.main.eager_load_dir(Rails.root.join("app/models"))

        drawn_root_routes = root_routes.dup
        drawn_nested_routes = nested_routes.dup

        router.instance_exec(drawn_root_routes, drawn_nested_routes) do |rr, nr|
          rr.each do |route|
            children = nr[route[:name]]
            if children&.any?
              resources route[:name] do
                children.each { |child| resources child[:name], module: child[:module] }
              end
            else
              resources route[:name]
            end
          end
        end
      end      
    end
  end
end