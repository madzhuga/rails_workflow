module RailsWorkflow
  class OperationWorker
    include Sidekiq::Worker

    def perform(operation_id)
      operation = Operation.find operation_id
      operation.execute_in_transaction
    end
  end
end
