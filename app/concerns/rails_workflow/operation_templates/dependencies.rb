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

        # When some operation changes its status engine tries to
        # resolve dependencies to understand if a new operation
        # should be created.
        # For example, if operation A depends on B (DONE) and C (DONE),
        # by default it will be created if any of B or C changed status
        # to DONE.
        # Overwriting this method on some specific operation template
        # allows you to modify this logic - for example, to build
        # dependency B (DONE) AND C(DONE) etc.
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
