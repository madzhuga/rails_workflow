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
          operations.size > 0
        end

        def start
          if can_start?
            update_attribute(:status, self.class::IN_PROGRESS)
            self.operations.where(status: RailsWorkflow::Operation::NOT_STARTED).map(&:start)
          end
        end

        def operation_exception
          self.status = self.class::ERROR
        end

        # Process can be completed if all sync operations is complete.

        def can_complete?
          if incomplete_statuses.include? status
            incompleted_operations.size == 0 &&
                workflow_errors.unresolved.size == 0
          else
            false
          end
        end

        # Returns set or operation that not yet completed.
        # Operation complete in DONE, SKIPPED, CANCELED, etc many other statuses
        def incompleted_operations
          operations.reject{|operation| operation.completed? }
        end

        # If operation is completed process is responsible for building new operations.
        # We need to calculate operations, depends on completed one and detect ones we
        # can build.
        def operation_complete operation
          build_dependencies operation
        end

        def complete
          self.status = self.class::DONE if can_complete?
          save
          if parent_operation.present?
            parent_operation.complete
          end
        end
      end

    end
  end
end