require 'active_support/concern'
module RailsWorkflow
  module ProcessTemplates
    # DefaultBuilder is responsible for building new process and it's initial (independent) operations.
    module DefaultBuilder
        extend ActiveSupport::Concern




        # When process manager building new process, it initializes process template for new process and
        # call this method to build new process instance.
        # This method buildling new process and initial operations (operations that has no dependencies on any
        # other operations and can be build before process starts).
        # @param [RailsWorkflow::Context] context for new process
        def build_process! context
          process = process_class.create template: self

          process.class.transaction do
            process.update_attributes({title: self.title, status: Process::NOT_STARTED})
            process.create_context(data: context, parent: process)

            build_independent_operations process
            process.reload
            build_process(process) if respond_to? :build_process
            process

          end

        end

        # Independent operations is template operations that have no dependencies on any other operations.
        def build_independent_operations process
          independent_operations.each do |operation_template|
            build_operation process, operation_template
          end
        end

        # Building new operation for given process.
        # @param [RailsWorkflow::Process] process to which new operation will be added.
        # @param [RailsWorkflow::OperationTEmplate] template which should be used to build new operation
        # @param [Array<RailsWorkflow::Operation>] completed_dependencies is process operaitons which was completed (or changed statuses) and caused this new operation creation.
        def build_operation process, template, completed_dependencies = []
          operation = template.build_operation! process, completed_dependencies

          if operation.present?
            process.operations << operation
          end

          operation
        rescue => exception
          RailsWorkflow::Error.create_from(
              exception, {
                           parent: process,
                           target: process.template,
                           method: :build_operation,
                           args: [process, template, completed_dependencies]
                       }
          )

        end


      end
    end
end
