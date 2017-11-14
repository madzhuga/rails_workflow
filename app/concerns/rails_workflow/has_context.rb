# frozen_string_literal: true

require 'active_support/concern'

module RailsWorkflow
  module HasContext
    extend ActiveSupport::Concern

    included do
      has_one :context, class_name: 'RailsWorkflow::Context', as: :parent
      
      after_save :save_context
      def save_context
        context&.save
      end
    end
  end
end
