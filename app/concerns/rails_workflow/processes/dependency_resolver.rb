# frozen_string_literal: true

module RailsWorkflow
  module Processes
    # = DependencyResolver
    #
    # New operation can be added to process if all it's dependencies
    # are satisfied. For example current operation can depend on some
    # existing process operation which should be completed - then current
    # operation can be build
    module DependencyResolver
      extend ActiveSupport::Concern

      included do
        # This methods get's operations that depends on given one.
        # Operation::DependencyResolver resolves operation template dependencies
        # but we can define dependencies not only by template but by some other
        # business logic on process level. That is why I splitted operation
        # dependencies on process and operation level
        #
        def build_dependencies(operation)
          new_operations = []

          matched_templates(operation).each do |operation_template|
            completed_dependencies = [operation]

            next unless operation_template.resolve_dependency operation
            new_operations << operation_builder.new(
              self, operation_template, completed_dependencies
            ).create_operation
          end

          new_operations.each do |new_operation|
            next unless incomplete_statuses.include?(status)
            operations << new_operation
            # TODO: Move out from here - it should not start operations here
            # It only should build them.
            operation_runner.new(new_operation).start
          end
        rescue => exception
          error_manager.handle(
            exception,
            parent: self, target: self, method: :build_dependencies,
            args: [operation]
          )
        end

        private

        def error_manager
          config.error_manager
        end

        def config
          RailsWorkflow.config
        end

        def operation_runner
          config.operation_runner
        end

        def operation_builder
          config.operation_builder
        end

        def matched_templates(operation)
          template.dependent_operations(operation) - operations.map(&:template)
        end
      end
    end
  end
end
