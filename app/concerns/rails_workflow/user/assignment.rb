module RailsWorkflow
  module User
    module Assignment
      extend ActiveSupport::Concern

      included do
        has_many :operations, class: RailsWorkflow::Operation, as: :assignment


        def self.role_text role
          if role.present?
            get_rassoc get_role_values, role
          end
        end

        def self.group_text group
          if group.present?
            get_rassoc get_group_values, group
          end
        end

        private
        def get_rassoc values, value
          values.rassoc(vaule.to_s) || values.rassoc(value.to_sym)
        end

      end
    end
  end
end