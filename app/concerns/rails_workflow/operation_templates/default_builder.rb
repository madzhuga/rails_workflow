module RailsWorkflow
  module OperationTemplates
    module DefaultBuilder
      extend ActiveSupport::Concern


      # Used to customize operation. Also can be used to update operation context
      #
      #   class NewOperationTemplate < RailsWorkflow::OperationTemplate
      #     def build_operation operation
      #       operation.title += " ##{resource.id}"
      #       operation.data[:someFlag] = true # adding someFlag to operation context.
      #     end
      #   end
      #
      # @param [RailsWorkflow::Operation] new operation
      # @return [void]
      def build_operation operation
        #for customization
      end

      # @private
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


      # Building context for new operation using dependencies. By default
      # it takes old operation's context copy for new operation. Independent operations
      # have no previous operations so they use process context.
      #
      # Main idea of this method is to have ability to use few dependencies context
      # (merge context of few operations etc). In fact you can use {#build_operation}
      # method to add all you need to context.
      #
      #   class NewOperationTemplate < RailsWorkflow::OperationTemplate
      #     def self.build_context operation
      #       context = dependencies.first.try(:context).try(:data)
      #       context[:user] = User.find(1) #adding user to context
      #       context[:isValid] = false # adding flag to context
      #     end
      #   end
      #
      # @see RailsWorkflow::Context
      # @return [RailsWorkflow::Context]
      def self.build_context dependencies
        dependencies.first.try(:context).try(:data)
      end

      # @private
      def self.build_context! operation, dependencies
        RailsWorkflow::Context.new(
            parent: operation,
            data: build_context(dependencies) || operation.process.data)
      end



    end
  end
end