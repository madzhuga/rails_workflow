# frozen_string_literal: true

module RailsWorkflow
  # Default class to describe User operation.
  # It describes two main differences of user
  # operation - that it can't start automaticaly
  # (only user can start it) and that it can be
  # assigned to any user. This way this class can be
  # used later as base class. There is two examples:
  # UserByGroupOperation - where user groups used to
  # split permissions to complete operations
  # and UserByRoleOperation where user roles used to
  # split permissions to complete operations.
  class UserOperation < Operation
    def can_start?
      false
    end

    def can_be_assigned?(_user)
      true # any user can complete operation
    end
  end
end
