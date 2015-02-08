module Workflow
  class OperationTemplate < ActiveRecord::Base
    include OperationStatus
    include OperationTemplates::Dependencies
    include OperationTemplates::Assignments
    include OperationTemplates::DefaultBuilder

    belongs_to :process_template, class_name: 'Workflow::ProcessTemplate'
    belongs_to :child_process, class_name: 'Workflow::ProcessTemplate'

    class << self

      def types
        Workflow.config.operation_types
      end

      # by default system using context data of first dependnecy
      # the one that triggered current operation build
      def build_context dependencies
        dependencies.first.try(:context).try(:data)
      end

      def build_context! operation, dependencies
        Workflow::Context.new(
            parent: operation,
            data: build_context(dependencies) || operation.process.data)
      end

    end



    def operation_class
      get_class(:operation_class, default_class(kind.to_sym))
    end

    def default_type
      Workflow.config.default_operation_template_type
    end

    def resolve_dependency operation
      true
    end

    def resolve_dependency! operation
      resolve_dependency operation
    end

    private
    def default_class kind
      Workflow.config.operation_types[kind][:class]
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
