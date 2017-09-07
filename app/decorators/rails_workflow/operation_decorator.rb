
# frozen_string_literal: true

module RailsWorkflow
  class OperationDecorator < OperationHelperDecorator
    delegate_all
    decorates_association :template, with: OperationTemplateDecorator

    def context
      ContextDecorator.decorate object.context
    end

    def process
      object.process.decorate
    end

    def async
      object.async ? 'Yes' : 'No'
    end

    def is_background
      object.is_background ? 'Yes' : 'No'
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

    def show_template_dependencies
      template.show_dependencies
    end
  end
end
