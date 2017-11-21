# frozen_string_literal: true

module RailsWorkflow
  # Operation builder which creates new operaitons including
  # their context, child processes etc... s
  class OperationBuilder
    attr_accessor :process, :template, :completed_dependencies
    delegate :attributes, :operation_class, :child_process, to: :template

    def initialize(process, template, completed_dependencies = [])
      @process = process
      @template = template
      @completed_dependencies = completed_dependencies
    end

    def create_operation
      create_operation!.tap { |operation| process.operations << operation }
    rescue => exception
      handle_exception(exception)
    end

    def create_operation!
      operation = operation_class.create(prepared_attributes) do |new_operation|
        new_operation.context = build_context(
          new_operation, completed_dependencies
        )

        after_operation_create(new_operation)
      end

      build_child_process(operation)
      operation
    end

    def after_operation_create(operation)
      return unless template.respond_to?(:after_operation_create)
      template.after_operation_create(operation)
    end

    def prepared_dependencies
      completed_dependencies.map do |dep|
        {
          operation_id: dep.id,
          status: dep.status
        }
      end
    end

    private

    def prepared_attributes
      attributes.with_indifferent_access
                .slice(:title, :async, :is_background)
                .merge(template: template,
                       tag: template.tag,
                       process: process,
                       status: Operation::NOT_STARTED,
                       manager: process.manager,
                       dependencies: prepared_dependencies)
    end

    def build_child_process(operation)
      return unless child_process.present?

      # TODO: replace with Process Builder or replace with
      # config process manager
      operation.child_process = RailsWorkflow::ProcessManager
                                .create_process(
                                  child_process.id,
                                  operation.context.data
                                )
    end

    def prepare_context_data(dependencies)
      dependencies.first.try(:context).try(:data)
    end

    # TODO: move to ContextBuilder
    def build_context(operation, dependencies)
      RailsWorkflow::Context.new(
        parent: operation,
        data: prepare_context_data(dependencies) || operation.process.data
      )
    end

    def handle_exception(exception)
      error_builder.handle(
        exception,
        parent: process, target: :operation_builder, method: :create_operation,
        args: [process, template, completed_dependencies]
      )
    end

    def error_builder
      config.error_builder
    end

    # TODO: move config
    def config
      RailsWorkflow.config
    end
  end
end
