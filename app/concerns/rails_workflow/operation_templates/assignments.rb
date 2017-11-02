
# frozen_string_literal: true

module RailsWorkflow
  module OperationTemplates
    module Assignments
      extend ActiveSupport::Concern

      included do
        belongs_to :assignment, polymorphic: true, required: false
        scope :for_user, ->(user) {
          keys = RailsWorkflow.config.assignment_by.select { |k| user.respond_to? k }

          assignment_condition = keys.map do |key|
            "rails_workflow_operation_templates.#{key} = ?"
          end.join(' or ')

          where(
            assignment_condition,
            *keys.map { |k| user.send(k) }
          )
        }
      end
    end
  end
end
