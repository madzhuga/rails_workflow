# frozen_string_literal: true

module RailsWorkflow
  # Stores error information
  class Error < ActiveRecord::Base
    belongs_to :parent, polymorphic: true
    has_one :context, class_name: 'RailsWorkflow::Context', as: :parent
    scope :unresolved, -> { where('resolved is null or resolved = false') }

    delegate :data, to: :context

    # def initialize(*args)
    #   binding.pry
    #   super(*args)
    # end

    # TODO move to error manager
    def retry
      update_attribute(:resolved, true)

      target = data[:target]
      method = data[:method]
      args = data[:args]

      target.send(method, *args)

      operation = parent if parent.is_a? RailsWorkflow::Operation

      process = if operation
                  operation.process
                elsif target.is_a? RailsWorkflow::Process
                  target
                elsif parent.is_a? RailsWorkflow::Process
                  parent
                end

      if operation.present?
        operation.reload
        if operation.status == Status::ERROR
          operation.update_attribute(:status, Status::NOT_STARTED)
        end
      end

      return unless process.present? && can_restart_process(process)

      process.update_attribute(:status, Status::IN_PROGRESS)
      process.start
    end

    # TODO move to process
    def can_restart_process(process)
      process.workflow_errors
             .unresolved.where.not(id: id).count.zero?
    end
  end
end
