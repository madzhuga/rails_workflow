require 'active_support/concern'

module RailsWorkflow
  module ProcessStatus
    extend ActiveSupport::Concern

    included do
      NOT_STARTED = 0
      IN_PROGRESS = 1
      DONE = 2

      WAITING = 3
      ERROR = 4

      #operation was in progress and canceled
      CANCELED = 5

      #operation was build but not started and not need to start
      SKIPPED = 6

      #current operation was in progress or complete
      #when process restart or rollback to some previous operation happened
      #this operation is moved to rollback so that rollback operation
      #can be added to template.
      #rollback operation can be used to cancel all changes
      #done by current operation before restart happened
      ROLLBACK = 7

      def self.get_status_code status
        case status
        when "in_progress"
          IN_PROGRESS
        when "done"
          DONE
        when "not_started"
          NOT_STARTED
        when "waiting"
          WAITING
        when "error"
          ERROR
        end
      end

      #this method returns set of statuses meaning that process is working
      def processing_statuses
        [IN_PROGRESS, WAITING]
      end

      def get_status_values
        [
            [NOT_STARTED, 'Not Started'],
            [IN_PROGRESS, 'In Progress'],
            [DONE, 'Done'],
            [WAITING, 'Waiting'],
            [ERROR, 'Error'],
            [CANCELED, 'Canceled'],
            [SKIPPED, 'Skipped'],
            [ROLLBACK, 'Rollback']
        ]
      end


    end

  end
end
