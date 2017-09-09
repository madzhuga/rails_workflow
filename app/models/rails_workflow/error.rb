# frozen_string_literal: true

module RailsWorkflow
  # Stores error information
  class Error < ActiveRecord::Base
    belongs_to :parent, polymorphic: true
    has_one :context, class_name: 'RailsWorkflow::Context', as: :parent
    scope :unresolved, -> { where('resolved is null or resolved = false') }

    delegate :data, to: :context

    # TODO: move to process
    def can_restart_process(process)
      process.workflow_errors
             .unresolved.where.not(id: id).count.zero?
    end

    # TODO: move to error manager
    # TODO: check specs
    def retry
      update_attribute(:resolved, true)

      target.send(data[:method], *data[:args])

      reset_operation_status

      try_restart_process
    end

    # TODO: check if it's covered by tests
    def reset_operation_status
      retunr unless operation && operation.reload.status == Status::ERROR

      operation.update_attribute(:status, Status::NOT_STARTED)
    end

    def target
      data[:target]
    end

    def operation
      parent if parent.is_a? RailsWorkflow::Operation
    end

    def try_restart_process
      return unless process.present? && can_restart_process(process)

      process.update_attribute(:status, Status::IN_PROGRESS)
      process.start
    end

    def process
      if operation
        operation.process
      elsif target.is_a? RailsWorkflow::Process
        target
      elsif parent.is_a? RailsWorkflow::Process
        parent
      end
    end
  end
end
