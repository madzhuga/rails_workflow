module RailsWorkflow
  module Processes
    # This module contains methods for starting/completing process, operations etc.
    #
    module DefaultRunner
      extend ActiveSupport::Concern

      # Checks if current process can start.
      # @return [boolean] true if process can start and false otherwise.
      def can_start?
        operations.size > 0
      end

      # Starting process and all independent operations that exists in process.
      def start
        if can_start?
          update_attribute(:status, self.class::IN_PROGRESS)
          self.operations.where(status: RailsWorkflow::Operation::NOT_STARTED).map(&:start)
        end
      end

      # Processing operation exceptions. By default just set ERROR status for process.
      def operation_exception
        self.status = self.class::ERROR
      end

      # Checks if process can be completed. Process can be completed if it has IN_PROGRESS or NOT_STARTED status and
      # all it's operaitons completed and all it's errors are resolved.
      # @return [boolean] true if process can be completed and false if not.
      def can_complete?
        if incomplete_statuses.include? status
          incompleted_operations.size == 0 &&
              workflow_errors.unresolved.size == 0
        else
          false
        end
      end

      # Returns set or operation that not yet completed.
      # Completed operation has DONE, SKIPPED, CANCELED, etc statuses
      def incompleted_operations
        operations.reject{|operation| operation.completed? }
      end

      # If operation is completed process is responsible for building new operations.
      # We need to calculate operations, depends on completed one and detect ones we
      # can build.
      def operation_complete operation
        build_dependencies operation
      end

      # Completing process. If current process has parent operation - tries to complete it.
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
