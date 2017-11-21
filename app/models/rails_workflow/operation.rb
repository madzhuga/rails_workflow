# frozen_string_literal: true

module RailsWorkflow
  # Operation is a key building block for a Rails Workflow.
  # This model is used to save operation meta data, describe relation
  # with operation context etc.
  class Operation < ActiveRecord::Base
    include OperationStatus
    include Operations::Dependencies
    # TODO: move to UserOperation
    include Operations::Assignments
    include HasContext

    belongs_to :process, class_name: 'RailsWorkflow::Process'
    alias parent process
    belongs_to :template, class_name: 'RailsWorkflow::OperationTemplate'
    belongs_to :child_process,
               class_name: 'RailsWorkflow::Process', required: false
    has_many :workflow_errors, class_name: 'RailsWorkflow::Error', as: :parent

    delegate :data, to: :context
    delegate :role, :multiple?, :group, to: :template
    delegate :start, :complete, :skip, :cancel, to: :runner

    scope :with_child_process, -> { where.not(child_process: nil) }
    scope :uncompleted, -> { where(status: user_ready_statuses) }
    scope :events, lambda {
      joins(:template)
        .where(rails_workflow_operation_templates: { kind: 'event' })
    }

    scope :without_events, lambda {
      joins(:template)
        .where.not(rails_workflow_operation_templates: { kind: 'event' })
    }

    def instruction
      template.instruction
    end

    def tag
      read_attribute(:tag) || template.tag
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

    def execute
      true
    end

    # This method allows you to add requirements for operation to start.
    # For example some operation can't start because of some process
    # or overall system conditions.
    # By default any operation can start :)
    def can_start?
      status.in? [Status::NOT_STARTED, Status::IN_PROGRESS]
    end

    def completed?
      completed_statuses.include? status
    end

    def completable?
      child_process_done?
    end

    def can_be_continued_by?(user, current_operation)
      waiting? &&
        assigned_to?(user) &&
        (current_operation.nil? || current_operation != self)
    end

    private

    def child_process_done?
      child_process.nil? || child_process.status == Status::DONE
    end

    def config
      RailsWorkflow.config
    end

    def runner
      @runner ||= config.operation_runner.new(self)
    end
  end
end
