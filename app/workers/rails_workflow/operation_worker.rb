module RailsWorkflow

  # Sidekiq background worker which processing operations.
  class OperationWorker
    include Sidekiq::Worker

    # @param operation_id which will be executed
    def perform(operation_id)
      operation = Operation.find operation_id
      operation.execute_in_transaction
    end
  end
end
