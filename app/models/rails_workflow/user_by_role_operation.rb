module RailsWorkflow
  class UserByRoleOperation < Operation
    def can_start?
      false
    end

    def can_be_assigned?(user)
      super && (template.role == user.role)
    end
  end
end
