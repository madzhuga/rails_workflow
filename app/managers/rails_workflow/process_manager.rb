module RailsWorkflow

  # By default ProcessManager responsible for building, starting and completing process.
  # In future I am planing to extend it with additional functions - for example to broadcast
  # messages between different processes and other functions.
  # Right now this is very basic manager class.
  class ProcessManager

    class << self

      # Building process using template and context.

      # @param template_id [integer] Id of process template which will be used to build new process.
      # @param context [Hash] Context is basically just a hash to store some variables and propagate them between operations.
      # @see RailsWorkflow::Context

      # @return [RailsWorkflow::Process] Built but not yet running process in NOT_STARTED status with created (but not started) independent operations.
      # @see RailsWorkflow::OperationTemplates::Dependencies independent operations
      def build_process template_id, context
        template = RailsWorkflow::ProcessTemplate.find template_id
        template.build_process! context
      end

      # Building and starting process using template and context.

      # @param template_id [integer] Id of process template which will be used to build new process.
      # @param context [Hash] Context is basically just a hash to store some variables and propagate them between operations.
      # @see RailsWorkflow::Context

      # @return [RailsWorkflow::Process] Running process with IN_PROGRESS status. Independent operations is build and running.
      # @see RailsWorkflow::OperationTemplates::Dependencies.inindependent operations
      def start_process template_id, context
        process = build_process template_id, context
        process.try(:start)
        process
      end
    end

    # @return [RailsWorkflow::Process] process manager's current process
    attr_accessor :process

    # @return [RailsWorkflow::ProcessTemplate] template of process manager's current proces.
    attr_accessor :template

    def initialize process = nil
      if process
        @process = process
        @template = process.template
      end
    end

    # Starts current process

    def start_process
      process.start
    rescue => exception
      RailsWorkflow::Error.create_from exception, parent: process
    end

    # Processing operation exceptions. In current realization just set
    # process to ERROR status.

    def operation_exception
      process.operation_exception
    end

    # Every operation informs manager when it's complete or changing it's status.
    # When operation complete, process manager searching for new operations to
    # create or complete process.

    def operation_complete operation
      process.operation_complete operation

      complete_process
    end

    # Checks if process can be completed and completes it.
    # @see RailsWorkflow::Processes::DefaultRunner.can_complete?
    # @see RailsWorkflow::Processes::DefaultRunner.complete

    def complete_process
      if process.can_complete?
        process.complete

      end
    end
  end
end
