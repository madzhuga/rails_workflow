module RailsWorkflow
  class ErrorWorker
    include Sidekiq::Worker

    def perform(parent_id, parent_class)
      parent = parent_class.constantize.find(parent_id)
      parent.status = parent.class::ERROR
      parent.save

      if parent.respond_to?(:parent_operation) &&
             parent.parent_operation.present?

        perform(
            parent.parent_operation.id,
            parent.parent_operation.class.to_s
        )

      end

      if parent.respond_to?(:process) &&
          parent.process.present?
        perform(parent.process.id, parent.process.class.to_s)
      end

    end
  end
end
