module RailsWorkflow
  # Every process contains one or more operations. If you navigate to any process you will see that process operations
  # list:
  #
  # http://madzhuga.github.io/rails_workflow/images/process_operations.png
  #
  # There is two types of operations: auto operations and user operations.
  # Auto operations using #execute method to perform some business logic. This #execute method is running is nested
  # transaction and can be running in background (using sidekiq). All you have to do is enable sidekiq in configuration
  # and check 'Run in background' on operation template.
  #
  # User operations waiting for user to complete. They also have #on_complete method where you can add some code
  # to run after user completes operation.
  #
  # Auto operations get's executed right after they are started. User operations set to WAITING status and waiting for user
  # to complete them.
  #
  # User operations may be assigned to some users by their role or group. You can use following helpers in your application
  # controllers: #assigned_operations, #available_operations, #current_operation.
  #
  # For example you can complete current user operation when it updates some resource:
  #   def update
  #     update! do |success, failure|
  #       success.html do
  #         # checks if there is current operation and user clicked 'Complete' button
  #         if current_operation && (params['commit'] == 'Complete')
  #           current_operation.complete
  #         end
  #
  #         redirect_to sales_contacts_path
  #     end
  #   end
  # end
  #
  # Assigned operations - is operations that is assigned to this exact user. For example user can start some operation
  # and then switch to some other operation. This way first operation user picked up is assigned to him but it is assigned
  # to that user and not yet completed.
  #
  # Available operations - if operation is not yet assigned to some specific user and current user has role/group
  # for which this operation is created then this user can pickup such operation and complete it.
  #
  # assigned_operations and available_operations helpers both returns only incompleted user operations.
  #
  class Operation < ActiveRecord::Base
    include OperationStatus

    include Operations::DefaultRunner
    include Operations::Dependencies
    include Operations::Assignments

    belongs_to :process, class_name: "RailsWorkflow::Process"
    belongs_to :template, class_name: "RailsWorkflow::OperationTemplate"
    belongs_to :child_process, class_name: "RailsWorkflow::Process"
    has_one :context, class_name: "RailsWorkflow::Context", as: :parent
    has_many :workflow_errors, class_name: "RailsWorkflow::Error", as: :parent

    delegate :data, to: :context
    delegate :role, to: :template
    delegate :group, to: :template

    scope :with_child_process, -> { where.not(child_process: nil) }
    scope :incompleted, -> { where(status: user_ready_statuses) }

    # @private
    def instruction
      self.template.instruction
    end

    # @private
    def manager
      @manager ||= process.manager
    end

    # @private
    def manager= manager
      @manager = manager
    end

  end
end
