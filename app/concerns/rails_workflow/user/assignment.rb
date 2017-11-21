# frozen_string_literal: true

module RailsWorkflow
  module User
    module Assignment
      extend ActiveSupport::Concern

      included do
        # TODO: change Operation to UserOperation
        has_many :operations, class_name: 'RailsWorkflow::Operation', as: :assignment
      end

      module ClassMethods
        def role_text(role)
          get_rassoc get_role_values, role if role.present?
        end

        def group_text(group)
          get_rassoc get_group_values, group if group.present?
        end

        def get_rassoc(values, value)
          (values.rassoc(value.to_s) || values.rassoc(value.to_sym)).try(:[], 0)
        end
      end
    end
  end
end
