module Workflow
  class ContextDecorator < Decorator
    def data
      if object.present?
        object.prepare_data object.data
      else
        {}
      end

    end
  end
end
