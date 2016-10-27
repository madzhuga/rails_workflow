module RailsWorkflow
  # ProcessManager should be used to build and start processes.
  # It is top level hierarchy class that also can be used
  # to build enhancements. For example they can be used to implement
  # processes communications.
  class ProcessManager
    attr_accessor :process, :template

    def self.build_process(template_id, context)
      template = RailsWorkflow::ProcessTemplate.find template_id
      template.build_process! context
    end

    def self.start_process(template_id, context)
      process = build_process template_id, context
      process.try(:start)
      process
    end

    def initialize(process = nil)
      @process = process
    end

    def template
      @template ||= @process.try(:template)
    end

    def start_process
      process.start
    rescue => exception
      RailsWorkflow::Error.create_from exception, parent: process
    end

    def operation_exception
      process.operation_exception
    end

    def operation_complete(operation)
      process.operation_complete operation

      complete_process
    end

    def complete_process
      process.complete if process.can_complete?
    end
  end
end
