# frozen_string_literal: true

module RailsWorkflow
  # Used to describe user operations which assignment
  # depends on user role.
  class UserByRoleOperation < UserOperation
    def can_be_assigned?(user)
      super && (template.role == user.try(:role))
    end
  end
end
