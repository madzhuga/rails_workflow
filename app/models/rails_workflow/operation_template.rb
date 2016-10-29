module RailsWorkflow
  class OperationTemplate < ActiveRecord::Base
    include OperationStatus
    include RailsWorkflow::Uuid
    include OperationTemplates::Dependencies
    include OperationTemplates::Assignments
    include OperationTemplates::DefaultBuilder

    belongs_to :process_template, class_name: 'RailsWorkflow::ProcessTemplate'
    belongs_to :child_process, class_name: 'RailsWorkflow::ProcessTemplate'

    scope :other_operations, ->(process_template_id, operation_template_id) {
      where(process_template_id: process_template_id)
        .where.not(id: operation_template_id)
    }

    def other_operations
      OperationTemplate.other_operations(process_template_id, id)
    end

    class << self
      def types
        RailsWorkflow.config.operation_types
      end
    end

    def operation_class
      get_class(:operation_class, default_class(kind.to_sym))
    end

    def default_type
      RailsWorkflow.config.default_operation_template_type
    end

    private

    def default_class(kind)
      RailsWorkflow.config.operation_types[kind][:class]
    end

    def get_class(symb, default)
      (read_attribute(symb).presence || default).constantize
    rescue
      default.constantize
    end
  end
end
