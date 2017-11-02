# frozen_string_literal: true

module RailsWorkflow
  module Operations
    module Assignments
      extend ActiveSupport::Concern

      included do
        belongs_to :assignment, polymorphic: true, required: false

        scope :by_role, ->(role) { joins(:template).where(rails_workflow_operation_templates: { role: role }) }
        scope :by_group, ->(group) { joins(:template).where(rails_workflow_operation_templates: { group: group }) }
        scope :unassigned, -> { where(assignment_id: nil) }

        scope :waiting, -> { where(status: Operation.user_ready_statuses) }

        scope :available_for_user, ->(user) {
          waiting.unassigned.joins(:template)
                 .merge(OperationTemplate.for_user(user))
        }

        scope :by_role_or_group, ->(role, group) do
          joins(:template).by_role_or_group(role, group)
        end

        scope :assigned_to, ->(user) {
          where(assignment_id: user.id, assignment_type: user.class.to_s)
        }

        def assigned?(user)
          assignment == user
        end

        def cancel_assignment(user)
          if assigned? user
            self.assignment = nil
            self.is_active = false
            save
          end
        end

        # can_assign_to will be used to check if user/group
        # can be assigned to operation
        def can_be_assigned?(_user)
          assignment.blank?
        end

        def assign_to(user)
          self.assignment = user
          self.is_active = true
          self.assigned_at = Time.zone.now

          self.class.assigned_to(user).update_all(is_active: false)

          save
        end

        def activate
          self.is_active = true
          save
        end

        def assign(user)
          ((assigned? user) && activate) || # if already assigned to user but unactive!
            (can_be_assigned?(user) && assign_to(user)) # user first time assigned to operation
        end
      end
    end
  end
end
