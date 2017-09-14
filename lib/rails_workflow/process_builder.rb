# frozen_string_literal: true

module RailsWorkflow
  # = DefaultBuilder
  #
  # Process Builder is used to build new process. All process building logic
  # should be gathered here. It defines how process is build using template
  # (for example it can used to gather some additional information from
  # system - for example some information from existing processes or it
  # can handle hierarchical processes logic for parent / child processes).
  class ProcessBuilder
    attr_accessor :template, :context

    delegate :process_class, :title, :independent_operations, to: :template

    def initialize(template, context)
      @template = template
      @context = context
    end

    def create_process!
      process = process_class.create(template: template)

      process.update_attributes(title: title, status: Process::NOT_STARTED)
      process.create_context(data: context, parent: process)

      build_independent_operations process
      process
    end

    # Independent operations is template operations that have no
    # dependencies from any other operations
    def build_independent_operations(process)
      independent_operations.each do |operation_template|
        build_operation process, operation_template
      end
    end

    def build_operation(process, template, completed_dependencies = [])
      operation_builder.new(
        process, template, completed_dependencies
      ).create_operation
    end

    def error_builder
      config.error_builder
    end

    def config
      RailsWorkflow.config
    end

    def operation_builder
      config.operation_builder
    end
  end
end
