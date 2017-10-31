# frozen_string_literal: true

# TODO: add spec
module RailsWorkflow
  #= ProcessRunner
  #
  # This module contains logic of process start, stop, cancel etc.
  #
  class ProcessRunner
    attr_reader :process

    delegate :uncompleted?, :can_start?, :operations,
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
    def completable?
      uncompleted? && workflow_errors.unresolved.size.zero?
    end

    def complete_parent_operation
      parent_operation.complete if parent_operation.present?
    end

    # TODO: change to try_complete
    def complete
      return unless completable?

      process.complete
      complete_parent_operation
    end

    def operation_completed(operation)
      build_new_operations(operation)
      complete
    end

    private

    def build_new_operations(operation)
      new_operations = dependency_resolver.build_new_operations(operation)

      return if new_operations.blank?

      operations.concat(new_operations)
      operation_runner.start(new_operations)
    end

    def operation_runner
      config.operation_runner
    end

    def dependency_resolver
      @dependency_resolver ||= config.dependency_resolver.new(process)
    end

    def config
      RailsWorkflow.config
    end
  end
end
