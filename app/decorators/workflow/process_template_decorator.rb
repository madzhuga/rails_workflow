module Workflow
  class ProcessTemplateDecorator < Decorator
    delegate_all

    def form
      'form'
    end

    def default_class
      Workflow.config.process_class
    end

    def default_manager
      Workflow.config.manager_class
    end

    def default_type
      Workflow.config.process_template_type
    end
  end
end