require 'active_support/concern'

module RailsWorkflow
  module OperationTemplates

    # = Dependencies
    #
    # Operation Template includes operation dependencies description. Example:
    #   Operation A depends on operation B in DONE status then
    #   operation A will be created when operation B will get DONE status.
    #
    # If operation depends on few statuses of other operation:
    #
    #   Operation A depends on operation B in DONE and IN_PROGRESS statuses then
    #   operation A will be created when operation B will get DONE or IN_PROGRESS status.
    #
    # If operation depends on few other operations
    #
    #   Operation A depends on operation B in DONE status or operation C in IN_PROGRESS status then
    #   operation A will be created when
    #     operation B gets DONE status
    #       (no matter if operation C exists and has IN_PROGRESS status or not)
    #     or operation C gets IN_PROGRESS status
    #       (no matter if operation B exists and has DONE status or not)
    #
    # This is default behaviour. You can customize it using {#resolve_dependencies} method
    #
    # Independen operations is operations with no dependencies. When process manager building new process, that process
    # building it's independent operations. When process manager starts process, process starts it's
    # independent operations.
    #

    module Dependencies

      extend ActiveSupport::Concern

        scope :independent_only, -> { where(dependencies: nil) }

        # This method allows you to define custom dependencies conditions.
        # @param operation [RailsWorkflow::Operation] is operation which status changed and current operation template checks if it's operation can be created.
        # @return [boolean]. Process creates new operation if method returns true
        #
        #   class NewOperationTemplate < RailsWorkflow::OperationTemplate
        #     def resolve_dependency operation
        #       operation.data[:orderValid]
        #     end
        #   end
        # In this example new operation will be created if (previous) operation's context variable :orderValid is true.
        # @see RailsWorkflow::Context for context details
        def resolve_dependency operation
          true
        end

        # Returns operation template dependecies. Each dependency is hash of
        #   {
        #     id: other_template_id,
        #     statuses: [DONE, IN_PROGRESS, etc]
        #   }
        #
        # @return [Array] of dependencies
        def dependencies
          read_attribute(:dependencies) || []
        end


    end
  end
end