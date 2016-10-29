module RailsWorkflow
  module Processes
    #= DefaultRunner
    #
    # This module contains logic of process start, stop, cancel etc.
    #
    module DefaultRunner
      extend ActiveSupport::Concern

      included do
        def can_start?
          !operations.empty?
        end

        def start
          if can_start?
            update_attribute(:status, self.class::IN_PROGRESS)
            operations.where(status: RailsWorkflow::Operation::NOT_STARTED).map(&:start)
          end
        end

        def operation_exception
          self.status = self.class::ERROR
        end

        # Process can be completed if all sync operations is complete.

        def can_complete?
          if incomplete_statuses.include? status
            incompleted_operations.size.zero? &&
              workflow_errors.unresolved.size.zero?
          else
            false
          end
        end

        # Returns set or operation that not yet completed.
        # Operation complete in DONE, SKIPPED, CANCELED, etc many other statuses
        def incompleted_operations
          operations.reject(&:completed?)
        end

        # If operation is completed process is responsible for building new operations.
        # We need to calculate operations, depends on completed one and detect ones we
        # can build.
        def operation_complete(operation)
          build_dependencies operation
        end

        def complete
          self.status = self.class::DONE if can_complete?
          save
          parent_operation.complete if parent_operation.present?
        end
      end
    end
  end
end
