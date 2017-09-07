# frozen_string_literal: true

module RailsWorkflow
  class ProcessTemplateDecorator < Decorator
    delegate_all

    def form
      'form'
    end

    def default_class
      RailsWorkflow.config.process_class
    end

    def default_manager
      RailsWorkflow.config.manager_class
    end

    def default_type
      RailsWorkflow.config.process_template_type
    end
  end
end
