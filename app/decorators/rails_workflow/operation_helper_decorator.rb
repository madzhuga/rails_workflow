# frozen_string_literal: true

module RailsWorkflow
  class OperationHelperDecorator < Decorator
    include StatusDecorator
    delegate :id, :title, :tag, :instruction, :complete, :data

    def assigned_to
      object.assignment.try(:email) || begin
        [
          assignment_by_role, assignment_by_group
        ].compact.join(', ')
      end
    end

    def assignment_by_role
      ::User.role_text(object.role) if object.role
    end

    def assignment_by_group
      ::User.group_text(object.group) if object.group
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
