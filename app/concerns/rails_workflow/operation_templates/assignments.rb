
module RailsWorkflow
  module OperationTemplates
    # = Assignments
    #
    # User operation template specifies role or group of users which can pickup and complete
    # operation.
    #

  module Assignments
      extend ActiveSupport::Concern

      included do
        belongs_to :assignment, polymorphic: true
        scope :for_user, -> (user) {

          keys = RailsWorkflow.config.assignment_by.select{|k| user.respond_to? k }

          assignment_condition = keys.map{|key|
            "rails_workflow_operation_templates.#{key} = ?" }.join(" or ")

          where(
              assignment_condition,
              *keys.map{|k| user.send(k) }
          )
        }
      end
    end
  end
end