# frozen_string_literal: true

require 'active_support/concern'

module RailsWorkflow
  module OperationStatus
    extend ActiveSupport::Concern
    include Status

    included do
      def self.user_ready_statuses
        [Status::WAITING]
      end
    end
  end
end
