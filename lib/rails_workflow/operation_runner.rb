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

    # TODO: refactor this mess
    def execute_in_transaction
      status = nil
      operation.class.transaction(requires_new: true) do
        begin
          child_process_runner.start if child_process.present?
          status = if operation.respond_to?(:execute)
                     operation.execute
                   else
                     true
                   end
        rescue ActiveRecord::Rollback
          status = nil
        end

        raise ActiveRecord::Rollback unless status
      end

      if status
        context.save
        complete
      end
    rescue ActiveRecord::Rollback => exception
      # In case of rollback exception we do nothing -
      # this may be caused by usual validations
    rescue => exception
      error_builder.handle(
        exception,
        parent: operation, target: :operation_runner,
        method: :execute_in_transaction
      )
    end

    def complete(to_status = Status::DONE)
      return unless completable?

      update_attributes(
        status: to_status,
        completed_at: Time.zone.now
      )
      process_runner.operation_completed(operation)
    end

    def cancel
      # before_cancel if respond_to? :before_cancel
      complete Status::CANCELED
    end

    def skip
      # before_cancel if respond_to? :before_skip
      complete Status::SKIPPED
    end

    private

    def error_builder
      config.error_builder
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
