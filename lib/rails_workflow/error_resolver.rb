# frozen_string_literal: true

module RailsWorkflow
  # Default error resolver. Can be changed in configuration.
  # Manages errors processing
  class ErrorResolver
    attr_accessor :error
    delegate :update_attribute, :target, :operation, :process,
             :data, :can_restart_process, to: :error

    def self.retry(error)
      new(error).retry
    end

    def initialize(error)
      @error = error
    end

    def retry
      update_attribute(:resolved, true)
      fix_status(error.parent)
      prepared_target.send(data[:method], *data[:args])
      try_restart_process unless target == 'process_manager'
    end

    def fix_status(subject)
      subject.status = Status::IN_PROGRESS
      subject.save
      fix_status(subject.parent) if subject.parent.present?
    end

    # TODO: check if it's covered by tests
    # TODO: check if it is redundant
    # def reset_operation_status
    #   return unless operation && operation.reload.status == Status::ERROR
    #
    #   operation.update_attribute(:status, Status::NOT_STARTED)
    # end

    def prepared_target
      return operation_runner if target == 'operation_runner'
      return operation_builder if target == 'operation_builder'
      return dependency_resolver if target == 'dependency_resolver'
      return process_manager if target == 'process_manager'
      target
    end

    # TODO: cover by spec
    def try_restart_process
      return unless process.present?
      process.update_attribute(:status, Status::IN_PROGRESS)
      # TODO: rename to can_restart_process?
      # TODO replace runner with manager?
      process.reload
      process_runner.start if can_restart_process(process)
    end

    def config
      RailsWorkflow.config
    end

    def process_manager
      config.process_manager.new(process)
    end

    def operation_runner
      config.operation_runner.new(operation)
    end

    def operation_builder
      config.operation_builder.new(*data[:args]).tap { data[:args] = nil }
    end

    def dependency_resolver
      config.dependency_resolver.new(process)
    end

    def process_runner
      config.process_runner.new(process)
    end
  end
end
