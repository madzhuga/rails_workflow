module RailsWorkflow
  # TODO: Remove this job
  # When some operation fails due to some exceptions this job
  # is responsible for setting operation to error status. Also it
  # check if there is parent processes / operations and set it
  # to error status.
  class OperationErrorJob < ActiveJob::Base
    queue_as :default

    def perform(*args)
      @target_id, @target_class = args

      target.status = target.class::ERROR
      target.save

      process_parents
    end

    private

    # Target is either operation or process
    def target
      @target ||= @target_class.constantize.find(@target_id)
    end

    # Target operation have parent process and target process may have
    # parent operation and they should also be moved to ERROR status
    def process_parents
      parent_methods.each do |parent_method|
        parent_target = target.public_send(parent_method)
        self.class.new.perform(parent_target.id, parent_target.class.to_s) if parent_target
      end
    end

    # Target operation respond to process, process respond to parent_operation
    def parent_methods
      [:parent_operation, :process]
        .select { |method_name| target.respond_to?(method_name) }
    end
  end
end
