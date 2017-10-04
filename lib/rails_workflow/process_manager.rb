# frozen_string_literal: true

module RailsWorkflow
  # ProcessManager should be used to build and start processes.
  # It is top level hierarchy class that also can be used
  # to build enhancements. For example they can be used to implement
  # processes communications.
  class ProcessManager
    attr_accessor :process, :template, :context
    # delegate :template, :operation_exception, to: :process
    delegate :complete, to: :process, prefix: true

    class << self
      def create_process(template_id, context)
        new(template_id: template_id, context: context).create_process
      end
    end

    def initialize(process = nil, template_id: nil, context: nil)
      @process = process
      @template = ProcessTemplate.find(template_id) if template_id
      @context = context
    end

    def create_process
      self.process = process_builder.new(template, context).create_process!
    end

    def self.start_process(template_id, context)
      process = create_process template_id, context
      new(process).start_process
      process
    end

    def start_process
      process_runner.start
    rescue => exception
      error_builder.handle(
        exception,
        parent: process,
        target: :process_manager,
        method: :start_process
      )
    end

    def complete_process
      process_runner.complete
    end

    def error_builder
      config.error_builder
    end

    def process_builder
      config.process_builder
    end

    def process_runner
      @process_runner ||= config.process_runner.new(process)
    end

    def config
      RailsWorkflow.config
    end
  end
end
