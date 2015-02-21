
module RailsWorkflow
  module Operations
    #
    # Workflow::Operations::DefaultRunner contains operation starting,
    # completing etc logic.
    #
    module DefaultRunner
      extend ActiveSupport::Concern

      # Checking if operation can start. If operation can't start it is switched
      # to WAITING status (for example user operations can't start and they are
      # waiting for user to pickup and complete them)
      def start
        can_start? ? starting : waiting
      rescue => exception
        RailsWorkflow::Error.create_from exception, parent: self
      end

      # Starting operation. Moves operation to IN_PROGRESS.
      # If sidekiq is enabled, operation is added to queue. If sidekiq is disabled
      # then executes operation inline
      def starting

        update_attribute(:status, self.class::IN_PROGRESS)

        is_background && RailsWorkflow.config.sidekiq_enabled ?
            OperationWorker.perform_async(id) :
            OperationWorker.new.perform(id)

      end

      # Checks if operation can start. By default just checks if operation
      # status is NOT_STARTED (ready to start).
      def can_start?
        status == Operation::NOT_STARTED
      end

      # Switching operation to WAITING status.
      def waiting
        update_attribute(:status, self.class::WAITING)
        start_waiting if respond_to? :start_waiting
      rescue => exception
        RailsWorkflow::Error.create_from exception, parent: self
      end

      # @private
      def execute_in_transaction
        begin

          status = nil
          self.class.transaction(requires_new: true) do
            begin
              if child_process.present?
                child_process.start
              end
              status = execute
            rescue ActiveRecord::Rollback
              status = nil
            end

            raise ActiveRecord::Rollback unless status
          end

          if status
            complete
          end

        rescue ActiveRecord::Rollback => exception
          # In case of rollback exception we do nothing -
          # this may be caused by usual validations
        rescue => exception
          RailsWorkflow::Error.create_from(
              exception, {
                           parent: self,
                           target: self,
                           method: :execute_in_transaction
                       }
          )

        end
      end

      # Main operation method that contains logic that should be executed in operation
      # Should return true if operation was executed successfully or false if not.
      # @return [boolean]
      def execute
        true
      end

      # Check if operation is completed. Checking if status is DONE, CANCELED or SKIPPED.
      # @return [boolean]
      def completed?
        completed_statuses.include? status
      end

      # Checking if can be completed. By default operation can't be completed if
      # it has not yet completed child process
      # @return [boolean]
      def can_complete?
        child_process.present? ?
            child_process.status == RailsWorkflow::Process::DONE :
            true
      end


      # Completing operation (checks if can complete).
      def complete
        if can_complete?
          on_complete if respond_to? :on_complete
          update_attributes(
              {
                  status: self.class::DONE,
                  completed_at: Time.zone.now
              })
          manager.operation_complete self
        end
      rescue => exception
        RailsWorkflow::Error.create_from(
            exception, {
                         parent: self,
                         target: self,
                         method: :complete

                     }
        )
      end



    end
  end
end