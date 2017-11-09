# frozen_string_literal: true

module RailsWorkflow
  class OperationTemplateDecorator < Decorator
    delegate_all

    def operation_class
      object.read_attribute(:operation_class).presence || object.operation_class
    end

    def type_title
      object.class.types[object.kind.to_sym][:title]
    end

    def async_text
      object.async ? 'Yes' : 'No'
    end

    def is_background_text
      object.is_background ? 'Yes' : 'No'
    end

    def other_operations
      if object.persisted?
        object.other_operations.order(id: :asc).to_a
      else
        # operations without current to build dependencies form part
        object.process_template.operations.to_a - [object]
      end
    end

    def default_class
      object.class.types[object.kind.to_sym][:class]
    end

    def default_type
      object.default_type
    end

    def form
      '_form'.dup.prepend(object.kind)
    end

    def assignment
      [assignment_by_role, assignment_by_group].compact.join(', ')
    end

    def assignment_by_role
      ::User.role_text(object.role) if object.role
    end

    def assignment_by_group
      ::User.group_text(object.group) if object.group
    end

    def show_dependencies
      if object.dependencies.present?

        object.dependencies.map do |dependency|
          depends_on = OperationTemplate.where(id: dependency['id']).pluck(:title).first
          statuses = object
                     .get_status_values
                     .select { |status| dependency['statuses'].include? status[0] }
          [depends_on] + statuses.map(&:last)
        end
      else
        []
      end
    end
  end
end
