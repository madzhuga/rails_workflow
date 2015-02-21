module RailsWorkflow
  # Every operation has operation template. This operation template allows you to configure operation and also
  # responsible for resolving dependencies (checking if need to create operation) and for building operation.
  #
  # http://madzhuga.github.io/rails_workflow/images/default_operation_template.png
  #
  # Default operation - is auto operation. As you can see on screenshot it has several fields:
  #
  # Operation class - allows you specify custom operation class. Operation need to have #execute method having code
  # you want operation to complete (if it is auto operation like in this example).
  #
  # Template class - allows you to specify custom operation template class. Template is responsible for resolving
  # dependencies (detecting if that operation should be created) and for building operation (including operation
  # context)
  #
  # Context Partial - allows you to specify custom partial for operation context. By default operation context partial
  # just showing context variables but you may change it to have links to your application resources included in context
  # or show some other usefull information on it.
  #
  # Child process - allows you to specify process, which operation will start when executing. Child process will use
  # that operation context as initial context. Such operation will be completed only when it's child process is
  # completed - untill then process will not be able to complete this operation and build it's dependant operations.
  # If child process gets ERROR status - this operation is also will get ERROR status.
  #
  # Asynchronous - allows you to set operation as asynchronous. This means that process will not wait for it's completion.
  # By default process is completed when all it's operation is completed. But in some cases you may need ability to complete
  # process even if some operations is not yet completed. For example overall process is completed but here is some minor
  # operation (child process) that is still in progress or waiting for something and it 'holds' process (and may be it's
  # parent process etc). This is when asynchronous operations are useful - process will not wait for such operations to
  # complete and may be completed having async operations still running.
  #
  # Run in background - allows you to set operation to run in sidekiq background process.
  #
  # There is also user by group and user by role operations in the system (you can create any custom operation you want
  # but default operation, user by group operation and user by role operation comes out of the box). They difference
  # is that they also have input to specify user group or role. Only users having such group or role will be able to
  # start and complete such operations.
  # User by group operation template:
  #
  # http://madzhuga.github.io/rails_workflow/images/new_user_operation_by_group.png
  #
  # and user by role:
  #
  # http://madzhuga.github.io/rails_workflow/images/new_user_operation_by_role.png
  #
class OperationTemplate < ActiveRecord::Base
    include OperationStatus
    include OperationTemplates::Dependencies
    include OperationTemplates::Assignments
    include OperationTemplates::DefaultBuilder

    belongs_to :process_template, class_name: "RailsWorkflow::ProcessTemplate"
    belongs_to :child_process, class_name: "RailsWorkflow::ProcessTemplate"

    scope :other_operations, ->(process_template_id, operation_template_id) {
      where(process_template_id: process_template_id).
          where.not(id: operation_template_id)
    }

    # Returns all operation templates except self
    # @return [Array<RailsWorkflow::OperationTemplate>]
    def other_operations
      OperationTemplate.other_operations(self.process_template_id, self.id)
    end


    class << self
      # @private
      # used for UI
      def types
        RailsWorkflow.config.operation_types
      end
    end



    private
    def operation_class
      get_class(:operation_class, default_class(kind.to_sym))
    end

    def default_type
      RailsWorkflow.config.default_operation_template_type
    end

    def default_class kind
      RailsWorkflow.config.operation_types[kind][:class]
    end

    def get_class symb, default
      begin
        (read_attribute(symb).presence || default).constantize
      rescue
        default.constantize
      end

    end

  end
end
