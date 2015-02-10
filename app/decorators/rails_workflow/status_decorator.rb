module RailsWorkflow
  module StatusDecorator
    extend ActiveSupport::Concern

    included do
      def status
        if object.status

          label_class = 'label-default'

          if object.status == object.class::DONE
            label_class = 'label-success'
          elsif [object.class::IN_PROGRESS, object.class::WAITING].include? object.status
            label_class = 'label-primary'
          elsif object.status == object.class::ERROR
            label_class = 'label-danger'
            #'warning'
          end

          text = object.get_status_values.
              detect { |status| object.status == status[0] }[1]

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