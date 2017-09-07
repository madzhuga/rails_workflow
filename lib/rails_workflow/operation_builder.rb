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
      build_operation!.tap { |operation| process.operations << operation }
    rescue => exception
      handle_exception(exception)
    end

    def build_operation!
      operation = operation_class.create(prepared_attributes) do |op|
        op.context = build_context(op, completed_dependencies)
        # Can add OperationTemplate#after_operation_create callback
        after_opeartion_create(op) if respond_to?(:after_operation_create)
      end

      build_child_process(operation)
      operation
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

    def build_context(operation, dependencies)
      RailsWorkflow::Context.new(
        parent: operation,
        data: prepare_context_data(dependencies) || operation.process.data
      )
    end

    def handle_exception(exception)
      # TODO: check retry works using those params
      error_manager.handle(
        exception,
        parent: process, target: process.template, method: :build_operation,
        args: [process, template, completed_dependencies]
      )
    end

    def error_manager
      config.error_manager
    end

    # TODO: move config
    def config
      RailsWorkflow.config
    end
  end
end
