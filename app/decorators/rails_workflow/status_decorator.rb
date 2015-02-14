module RailsWorkflow
  module StatusDecorator
    extend ActiveSupport::Concern

    included do
      def status
        if object.status

          label_class = case object.status
                          when object.class::DONE
                            'label-success'
                          when object.class::IN_PROGRESS..object.class::WAITING
                            'label-primary'
                          when object.class::ERROR
                            'label-danger'
                          else
                            'label-default'
                        end

          text = object.get_status_values.assoc(object.status)[1]

          {
              class: label_class,
              text: text
          }
        else
          {
              class: nil,
              text: nil,
          }
        end
      end

    end
  end
end