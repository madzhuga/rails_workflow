module RailsWorkflow
  module OperationTemplates
    module DefaultBuilder
      extend ActiveSupport::Concern

      def build_operation operation
        #for customization
      end

      def build_operation! process, completed_dependencies = []

        attrs = attributes.
            with_indifferent_access.
            slice(:title, :async, :is_background).
            merge({
                      template: self,
                      process: process,
                      status: Operation::NOT_STARTED,
                      manager: process.manager
                  })


        attrs[:dependencies] = completed_dependencies.map { |dep|
          {
              operation_id: dep.id,
              status: dep.status
          }
        }


        operation = operation_class.create(attrs) do |op|
          op.context = RailsWorkflow::OperationTemplate.build_context! op, completed_dependencies

          build_operation op
        end

        if child_process.present?
          operation.child_process = RailsWorkflow::ProcessManager.
              build_process(
                  child_process.id,
                  operation.context.data
              )
        end
        operation

      end

      module ClassMethods

        def build_context dependencies
          dependencies.first.try(:context).try(:data)
        end

        def build_context! operation, dependencies
          RailsWorkflow::Context.new(
              parent: operation,
              data: build_context(dependencies) || operation.process.data)
        end

      end

    end
  end
end