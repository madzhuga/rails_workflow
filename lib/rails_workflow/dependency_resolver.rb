# frozen_string_literal: true

module RailsWorkflow
  # DependencyResolver
  #
  # New operation can be added to process if all it's dependencies
  # are satisfied. For example current operation can depend on some
  # existing process operation which should be completed - then current
  # operation can be build
  class DependencyResolver
    attr_accessor :process

    delegate :template, :operations, :uncompleted_statuses, to: :process

    def initialize(process)
      @process = process
    end

    def build_new_operations(operation)
      [].tap do |new_operations|
        matched_templates(operation).each do |operation_template|
          completed_dependencies = [operation]

          new_operations << operation_builder.new(
            process, operation_template, completed_dependencies
          ).create_operation
        end
      end.compact
    rescue => exception
      handle_exception(exception, operation)
    end

    private

    def handle_exception(exception, operation)
      error_builder.handle(
        exception,
        parent: process, target: :dependency_resolver,
        method: :build_new_operations, args: [operation]
      )
    end

    def error_builder
      config.error_builder
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
      (dependent_templates(operation) - already_built_templates)
        .select do |operation_template|
          operation_template.resolve_dependency operation
        end
    end

    def dependent_templates(operation)
      template.dependent_operations(operation)
    end

    def already_built_templates
      operations.map(&:template)
    end
  end
end
