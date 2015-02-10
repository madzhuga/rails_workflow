require 'active_support/concern'
module RailsWorkflow
  module ProcessTemplates
    # = DefaultBuilder
    #
    # Process Builder is used to build new process. All process building logic should be
    # gathered here. It defines how process is build using template (for example it can used
    # to gather some additional information from system - for example some information from
    # existing processes or it can handle hierarchical processes logic for parent / child
    # processes).
    #
    module DefaultBuilder
        extend ActiveSupport::Concern

        included do


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

          # Independent operations is template operations that have no dependencies from
          # any other operations
          def build_independent_operations process
            independent_operations.each do |operation_template|
              build_operation process, operation_template
            end
          end

          # Important note: operation template contains Operation Class.
          # You can specify custom class on template


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
end
