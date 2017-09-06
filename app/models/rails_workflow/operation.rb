module RailsWorkflow
  # Operation is a key building block for a Rails Workflow.
  # This model is used to save operation meta data, describe relation
  # with operation context etc.
  class Operation < ActiveRecord::Base
    include OperationStatus

    include Operations::DefaultRunner
    include Operations::Dependencies
    include Operations::Assignments

    belongs_to :process, class_name: 'RailsWorkflow::Process'
    alias_method :parent, :process
    belongs_to :template, class_name: 'RailsWorkflow::OperationTemplate'
    belongs_to :child_process, class_name: 'RailsWorkflow::Process'
    has_one :context, class_name: 'RailsWorkflow::Context', as: :parent
    has_many :workflow_errors, class_name: 'RailsWorkflow::Error', as: :parent

    delegate :data, to: :context
    delegate :role, to: :template
    delegate :group, to: :template

    scope :with_child_process, -> { where.not(child_process: nil) }
    scope :incompleted, -> { where(status: user_ready_statuses) }

    def instruction
      template.instruction
    end

    def manager
      @manager ||= process.manager
    end

    attr_writer :manager

    def waiting?
      status.in? Operation.user_ready_statuses
    end

    def can_be_started_by?(user)
      waiting? && can_be_assigned?(user) && assignment.nil?
    end

    def assigned_to?(user)
      assignment && assignment == user
    end

    def can_be_continued_by?(user, current_operation)
      waiting? &&
        assigned_to?(user) &&
        (current_operation.nil? || current_operation != self)
    end
  end
end
