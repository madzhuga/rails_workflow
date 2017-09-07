# frozen_string_literal: true

module RailsWorkflow
  # Used to describe user operations which assignment
  # is depend on user group.
  class UserByGroupOperation < UserOperation
    def can_be_assigned?(user)
      super && (template.group == user.try(:group).to_s)
    end
  end
end
