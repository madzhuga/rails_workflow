module RailsWorkflow
  # ProcessManager should be used to build and start processes.
  # It is top level hierarchy class that also can be used
  # to build enhancements. For example they can be used to implement
  # processes communications.
  class ProcessManager
    attr_accessor :process
    delegate :template, :operation_exception, to: :process
    delegate :complete, to: :process, prefix: true

    def initialize(process = nil)
      @process = process
    end

    def self.build_process(template_id, context)
      RailsWorkflow::ProcessTemplate
        .find(template_id)
        .build_process!(context)
    end

    def self.start_process(template_id, context)
      process = build_process template_id, context
      new(process).start_process
      process
    end

    def start_process
      process.start
    rescue => exception
      RailsWorkflow::Error.create_from exception, parent: process
    end

    def operation_completed(operation)
      process.operation_complete operation
      process_complete
    end

    def complete_process
      process.complete
    end
  end
end
