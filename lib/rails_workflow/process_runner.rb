# frozen_string_literal: true

# TODO: add spec
module RailsWorkflow
  #= DefaultRunner
  #
  # This module contains logic of process start, stop, cancel etc.
  #
  class ProcessRunner
    attr_reader :process

    delegate :incomplete?, :can_start?, :operations,
             :workflow_errors, :parent_operation, to: :process

    def initialize(process)
      @process = process
    end

    def start
      return unless can_start?

      process.update_attribute(:status, Status::IN_PROGRESS)
      # TODO replace with OperationRunner
      operations.where(status: Status::NOT_STARTED).map(&:start)
    end

    # Process can be completed if all sync operations is complete
    def can_complete?
      incomplete? && workflow_errors.unresolved.size.zero?
    end

    # Returns set or operation that not yet completed.
    # Operation complete in DONE, SKIPPED, CANCELED, etc many other statuses
    def incompleted_operations
      operations.reject(&:completed?)
    end

    # When we complete operation, we need to check if we need to build some
    # new operations. We need to calculate operations, depends on completed
    # one and detect ones we can build.
    # TODO: replace with dependency resolver
    def operation_complete(operation)
      process.build_dependencies operation
    end

    def complete_parent_operation
      parent_operation.complete if parent_operation.present?
    end

    def complete
      return unless can_complete?

      process.complete
      complete_parent_operation
    end
  end
end
