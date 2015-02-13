module RailsWorkflow
  module User
    module Assignment
      extend ActiveSupport::Concern

      included do
        has_many :operations, class: RailsWorkflow::Operation, as: :assignment


        def self.role_text role
          if role.present?
            get_role_values.rassoc(role.to_s).try(:first) ||
                get_role_values.rassoc(role.to_sym).try(:first)
          end
        end

        def self.group_text group
          if group.present?
            get_group_values.rassoc(group.to_s).try(:first) ||
              get_group_values.rassoc(group.to_sym).try(:first)
          end
        end



      end
    end
  end
end