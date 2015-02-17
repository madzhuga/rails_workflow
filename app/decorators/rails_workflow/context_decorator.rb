module RailsWorkflow
  class ContextDecorator < Draper::Decorator

    def partial_name
      object.parent.template.partial_name.presence || "context"
    end

    def data
      if object.present?
        object.prepare_data object.data
      else
        {}
      end

    end
  end
end
