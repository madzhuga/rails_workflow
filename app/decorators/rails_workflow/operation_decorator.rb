
module RailsWorkflow
  class OperationDecorator < OperationHelperDecorator
    delegate_all

    def process
      object.process.decorate
    end

    def async
      object.async ? "Yes" : "No"
    end

    def is_background
      object.is_background ? "Yes": "No"
    end

    def child_process
      if object.child_process
        ::RailsWorkflow::ProcessDecorator.decorate(object.child_process)
      end
    end

    def show_dependencies
      if object.dependencies.present?
        object.dependencies.map do |dependency|
          Operation.find(dependency['operation_id']).decorate
        end
      else
        []
      end

    end

    def context
      ContextDecorator.decorate(object.context).data
    end

    def show_template_dependencies
      if object.dependencies.present?
        object.template.dependencies.map do |dependency|
          depends_on = OperationTemplate.where(id: dependency['id']).pluck(:title).first
          statuses = object.
              get_status_values.
              select{|status| dependency['statuses'].include? status[0]}
          [depends_on] + statuses.map(&:last)
        end
      else
        []
      end

    end

  end
end
