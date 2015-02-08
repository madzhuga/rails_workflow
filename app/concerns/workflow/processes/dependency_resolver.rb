module Workflow
  module Processes
    # = DependencyResolver
    #
    # New operation can be added to process if all it's dependencies are satisfied.
    # For example current operation can depend on some existing process operation which
    # should be completed - then current operation can be build

    module DependencyResolver
      extend ActiveSupport::Concern

      included do
        # This methods get's operations that depends on given one.
        # Operation::DependencyResolver resolves operation template dependencies
        # but we can define dependencies not only by template but by some other
        # business logic on process level. That is why I splitted operation
        # dependencies on process and operation level
        #
        def build_dependencies operation
          # template operations that depends on that given operation and it's status
          template_operations = template.dependent_operations(operation)

          new_operations = []
          # default implementation is not allowing to have few operations in process
          # having same operation template. One operation template = one operation in process.
          # Only error task's restart or process restart allowing to re-create operation few times.

          (template_operations - operations.map(&:template)).each do |operation_template|
            # this is templates that depends on given operation and
            # not yet added to process.

            completed_dependencies = [operation]
            if operation_template.resolve_dependency! operation
              new_operations << operation_template.build_operation!(self, completed_dependencies)
            end

          end

          new_operations.compact.each do |new_operation|
            if processing_statuses.include?(status)
              self.operations << new_operation
              new_operation.start
            end
          end
        rescue => exception
          Workflow::Error.create_from(
              exception, {
                           parent: self,
                           target: self,
                           method: :build_dependencies,
                           args: [operation]
                       }
          )

        end

        # # This method returns operations that can be build.
        # def solved_dependencies operation
        #   # operation_dependencies(operation).select{|dop| dop.}
        #   operation_dependencies(operation)
        # end





      end
    end
  end
end