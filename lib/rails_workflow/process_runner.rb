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
      # TODO: replace with OperationRunner
      operation_runner.start(operations.where(status: Status::NOT_STARTED))
    end

    # Process can be completed if all sync operations is complete
    def can_complete?
      incomplete? && workflow_errors.unresolved.size.zero?
    end

    def complete_parent_operation
      parent_operation.complete if parent_operation.present?
    end

    # TODO: change to try_complete
    def complete
      return unless can_complete?

      process.complete
      complete_parent_operation
    end

    def operation_completed(operation)
      # TODO: replace with dependency resolver
      process.build_dependencies operation
      complete
    end

    def operation_runner
      config.operation_runner
    end

    def config
      RailsWorkflow.config
    end
  end
end
