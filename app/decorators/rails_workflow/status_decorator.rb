# frozen_string_literal: true

module RailsWorkflow
  module StatusDecorator
    extend ActiveSupport::Concern

    included do
      def status
        if object.status
          {
            class: get_label_class(object),
            text: object.get_status_values.assoc(object.status)[1]
          }
        else
          {
            class: nil,
            text: nil
          }
        end
      end

      def get_label_class(object)
        case object.status
        when object.class::DONE
          'label-success'
        when object.class::IN_PROGRESS..object.class::WAITING
          'label-primary'
        when object.class::ERROR
          'label-danger'
        else
          'label-default'
        end
      end
    end
  end
end
