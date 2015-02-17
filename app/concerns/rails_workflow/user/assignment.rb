module RailsWorkflow
  module User
    module Assignment
      extend ActiveSupport::Concern

      included do
        has_many :operations, class: RailsWorkflow::Operation, as: :assignment

      end

      module ClassMethods

        def role_text role
          if role.present?
            get_rassoc get_role_values, role
          end
        end

        def group_text group
          if group.present?
            get_rassoc get_group_values, group
          end
        end

        def get_rassoc values, value
          values.rassoc(value.to_s) || values.rassoc(value.to_sym)
        end

      end

    end
  end
end