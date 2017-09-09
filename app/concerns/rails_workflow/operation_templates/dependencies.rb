# frozen_string_literal: true

require 'active_support/concern'

module RailsWorkflow
  module OperationTemplates
    # Dependencies defines which operations in which states should be.
    module Dependencies
      extend ActiveSupport::Concern

      included do
        serialize :dependencies, JSON
        scope :independent_only, lambda {
          where(
            "dependencies is null or dependencies = 'null' or dependencies='[]'"
          )
        }

        # This method can be overwritte on a specific operation templates
        # to implement complex logic calculating if this operation should
        # be created.
        # TODO chech if this method needs to know completed operation or
        # may be just a process to do necessary checks
        def resolve_dependency(_completed_operation)
          true
        end

        def dependencies
          read_attribute(:dependencies) || []
        end
      end
    end
  end
end
