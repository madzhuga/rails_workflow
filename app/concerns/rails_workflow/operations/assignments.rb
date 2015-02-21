module RailsWorkflow
  module Operations
    # User operation should be completed by some specific user. Operation template specifies user's that can
    # assign that operation. By default you can use user role or user group to specify users that can pickup and
    # complete operaitons but it can be customized.
    #
    # Only user operaitons in WAITING status can be assigned to user.
    module Assignments
      extend ActiveSupport::Concern

        # @private
        belongs_to :assignment, polymorphic: true

        # @private
        scope :by_role, -> (role) { joins(:template).where(rails_workflow_operation_templates: { role: role })}

        # @private
        scope :by_group, -> (group) { joins(:template).where(rails_workflow_operation_templates: { group: group })}

        # @private
        scope :unassigned, -> { where(assignment_id: nil) }

        # @private
        scope :waiting, -> { where( status: Operation.user_ready_statuses ) }

        # @private
        scope :available_for_user, -> (user) {
          waiting.unassigned.joins(:template).
            merge(OperationTemplate.for_user(user))
        }

        # @private
        scope :by_role_or_group, -> (role, group) do
          joins(:template).by_role_or_group(role, group)
        end

        # @private
        scope :assigned_to, -> (user) {
          where(assignment_id: user.id, assignment_type: user.class.to_s)
        }

        # Checking if operation is assigned to given user.
        # @param [User] user which will be used to check
        # @return [boolean] true if this operation assigned to given user or false.
        def assigned? user
          assignment == user
        end

        # Allows to cancel assignment operation from specific user. For example user has vacation and
        # somebody else should complete operation. In this case operation is no longer assigned to given user
        # and operation again assigned to role or group.
        # @param [User] user which will be used to check
        # @return [void]
        def cancel_assignment user
          if assigned? user
            self.assignment = nil
            self.is_active = false
            save
          end
        end

        # Checking if user can be assigned to current operation.
        # @param [User] user which will be used to check
        # @return [boolean] true if this operation can be assigned to given user or false.
        def can_be_assigned? user
          self.assignment.blank?
        end

        # Assigns operation to given user.
        # @param [User] user which will be used to check
        def assign_to user
          self.assignment = user
          self.is_active = true
          self.assigned_at = Time.zone.now

          self.class.assigned_to(user).update_all(is_active: false)

          save
        end

        # Active operation is one that user is working on right now. This is operation that 'current_operation' helper
        # returns. User may have only one active operation at the same time.
        def activate
          self.is_active = true
          save
        end

        # Assigns operation to given user. Checks if user can be assigned to given operation. It's safe to use that
        # method for operations that is already assigned to user - this way operation will be set to active current
        # user operation.
        # @param [User] user which will assigned to operation.
        def assign user
          ((assigned? user) && (activate)) || #if already assigned to user but unactive!
              (can_be_assigned?(user) && assign_to(user)) #user first time assigned to operation
        end

      end
    end
end