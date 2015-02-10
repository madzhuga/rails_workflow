module RailsWorkflow
  class ProcessManager
    class << self
      def build_process template_id, context
        template = RailsWorkflow::ProcessTemplate.find template_id
        template.build_process! context
      end

      def start_process template_id, context
        process = build_process template_id, context
        process.try(:start)
        process
      end
    end

    attr_accessor :process, :template

    def initialize process = nil
      if process
        @process = process
        @template = process.template
      end
    end

    def start_process
      process.start
    rescue => exception
      RailsWorkflow::Error.create_from exception, parent: process
    end

    def operation_exception
      process.operation_exception
    end

    def operation_complete operation
      process.operation_complete operation

      complete_process
    end

    def complete_process
      if process.can_complete?
        process.complete

      end
    end
  end
end
