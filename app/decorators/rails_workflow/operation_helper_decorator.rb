module RailsWorkflow
  class OperationHelperDecorator < Decorator
    include StatusDecorator
    delegate :id, :title, :instruction, :complete

    def assigned_to
      object.assignment.try(:email) || begin
        [
          ::User.role_text(object.role),
          ::User.group_text(object.group)
        ].compact.join(', ')
      end
    end

    def created_at
      object.created_at.strftime('%m/%d/%Y %H:%M')
    end

    def completed_at
      if object.completed_at.present?
        object.completed_at.strftime('%m/%d/%Y %H:%M')
      end
    end
  end
end
