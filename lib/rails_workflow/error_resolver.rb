# frozen_string_literal: true

module RailsWorkflow
  # Default error resolver. Can be changed in configuration.
  # Manages errors processing
  class ErrorResolver
    attr_accessor :error
    delegate :update_attribute, :target, :operation, :process,
             :data, :can_restart_process?, to: :error

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

    def prepared_target
      return operation_runner if target == 'operation_runner'
      return operation_builder if target == 'operation_builder'
      return dependency_resolver if target == 'dependency_resolver'
      return process_manager if target == 'process_manager'
      target
    end

    def try_restart_process
      return if process.nil? || process.status == Status::DONE
      process.update_attribute(:status, Status::IN_PROGRESS)

      process.reload
      process_runner.start if can_restart_process?
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
