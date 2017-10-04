# frozen_string_literal: true

module RailsWorkflow
  # Workflow::OperationRunner responsible for operation execution
  class OperationRunner
    attr_accessor :operation
    delegate :can_start?, :completed?, :completable?, :update_attribute,
             :update_attributes, :is_background, :child_process, :context,
             to: :operation

    def self.start(operations)
      operations.each do |operation|
        new(operation).start
      end
    end

    def initialize(operation)
      @operation = operation
    end

    def start
      can_start? ? starting : waiting
    rescue => exception
      error_builder.handle(
        exception,
        parent: operation, target: :operation_runner, method: :start
      )
    end

    def starting
      update_attribute(:status, Status::IN_PROGRESS)

      if is_background && config.activejob_enabled
        OperationExecutionJob.perform_later(operation.id)
      else
        OperationExecutionJob.perform_now(operation.id)
      end
    end

    def waiting
      update_attribute(:status, Status::WAITING)
      start_waiting if respond_to? :start_waiting
    rescue => exception
      error_builder.handle(
        exception,
        parent: operation,
        target: :operation_runner,
        method: :waiting
      )
    end

    def execute_in_transaction
      with_transaction do
        child_process_runner.start if child_process.present?
        operation.execute if operation.respond_to?(:execute)
        complete
      end
    rescue => exception
      handle_exception(exception)
    end

    def complete(to_status = Status::DONE)
      return unless completable?

      context&.save
      update_attributes(
        status: to_status,
        completed_at: Time.zone.now
      )
      process_runner.operation_completed(operation)
    end

    def cancel
      complete Status::CANCELED
    end

    def skip
      complete Status::SKIPPED
    end

    private

    def error_builder
      config.error_builder
    end

    def handle_exception(exception)
      error_builder.handle(
        exception,
        parent: operation, target: :operation_runner,
        method: :execute_in_transaction
      )
    end

    def with_transaction
      operation.class.transaction(requires_new: true) do
        yield
      end
    end

    def child_process_runner
      @child_process_runner ||= config.process_runner.new(child_process)
    end

    def process_runner
      @process_runner ||= config.process_runner.new(operation.process)
    end

    def config
      RailsWorkflow.config
    end
  end
end
