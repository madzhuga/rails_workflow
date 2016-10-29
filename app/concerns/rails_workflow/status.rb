require 'active_support/concern'

module RailsWorkflow
  module Status
    extend ActiveSupport::Concern

    NOT_STARTED = 0
    IN_PROGRESS = 1
    DONE = 2
    WAITING = 3
    ERROR = 4
    CANCELED = 5
    SKIPPED = 6
    ROLLBACK = 7

    module ClassMethods
      def all_statuses
        (NOT_STARTED..ROLLBACK).to_a
      end

      def get_status_code(status)
        case status
        when 'in_progress'
          IN_PROGRESS
        when 'done'
          DONE
        when 'not_started'
          NOT_STARTED
        when 'waiting'
          WAITING
        when 'error'
          ERROR
        end
      end
    end

    included do
      def incomplete_statuses
        [NOT_STARTED, IN_PROGRESS, WAITING]
      end

      def completed_statuses
        [DONE, CANCELED, SKIPPED, ROLLBACK]
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
