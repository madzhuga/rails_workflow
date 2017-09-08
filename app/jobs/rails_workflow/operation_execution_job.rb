# frozen_string_literal: true

module RailsWorkflow
  # Rails workflow operation can run in background
  # (if is_background = true). This job is responsible
  # for performing operation in background.
  class OperationExecutionJob < ActiveJob::Base
    queue_as :default

    def perform(*args)
      operation_id = args[0]

      operation = Operation.find operation_id
      operation_runner.new(operation).execute_in_transaction
    end

    def config
      RailsWorkflow.config
    end

    def operation_runner
      config.operation_runner
    end
  end
end
