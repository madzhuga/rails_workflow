module RailsWorkflow
  #
  # RailsWorkflow::UserByRoleOperation is user operation which uses user roles
  # for assignment. Here you can see it's template example:
  #
  # http://madzhuga.github.io/rails_workflow/images/new_user_operation_by_role.png
  class UserByRoleOperation < Operation

    #
    # When process tries to start operation, it checks if operation can start.
    # If operation can start then it starts and executes.
    # User operation can't start so it switched to WAITING status so that user
    # can pick up operation and complete it.
    # @return [boolean] false so that user operation waiting for user
    def can_start?
      false
    end

    #
    # Checks if current operation can be assigned to given user.
    # UserByRoleOperation implementation additionaly checks if user role is
    # equal to role specified in operation's template.
    # @param [User] user for which it should perform check.
    # @return [boolean] true if operation can be assigned to user or falce if not.
    def can_be_assigned? user
      super && (self.template.role == user.role)
    end


  end
end
