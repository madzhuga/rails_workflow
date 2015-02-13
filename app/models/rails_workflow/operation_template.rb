module RailsWorkflow
  class OperationTemplate < ActiveRecord::Base
    include OperationStatus
    include OperationTemplates::Dependencies
    include OperationTemplates::Assignments
    include OperationTemplates::DefaultBuilder

    belongs_to :process_template, class_name: "RailsWorkflow::ProcessTemplate"
    belongs_to :child_process, class_name: "RailsWorkflow::ProcessTemplate"

    scope :other_operations, -> {
      OperationTemplate.
          where(process_template_id: self.process_template_id).
          where.not(id: id)
    }

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
    def default_class kind
      RailsWorkflow.config.operation_types[kind][:class]
    end

    def get_class symb, default
      begin
        (read_attribute(symb).presence || default).constantize
      rescue
        default.constantize
      end

    end

  end
end
