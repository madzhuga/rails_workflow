# frozen_string_literal: true

module RailsWorkflow
  class ProcessDecorator < Decorator
    include StatusDecorator
    delegate_all

    def created_at
      object.created_at.strftime('%m/%d/%Y %H:%M')
    end

    def context
      ContextDecorator.decorate object.context
    end

    def parents
      if object.parent_operation.present?
        [self.class.decorate(object.parent_operation.process)]
      else
        []
      end
    end

    def children
      children = object.operations.with_child_process.map(&:child_process)
      if children.present?
        self.class.decorate_collection(children)
      else
        []
      end
    end

    def operations
      OperationDecorator.decorate_collection(object.operations.order(:id))
    end

    def future_operations
      operations = if object.operations.present?
                     object.operations.map(&:template)
                   else
                     []
                   end
      OperationTemplateDecorator
        .decorate_collection(
          object.template.operations - operations
        )
    end
  end
end
