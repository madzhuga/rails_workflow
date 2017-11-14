# frozen_string_literal: true

module RailsWorkflow
  # Stores error information
  class Error < ActiveRecord::Base
    include HasContext
    belongs_to :parent, polymorphic: true, required: false
    scope :unresolved, -> { where('resolved is null or resolved = false') }

    delegate :data, to: :context
    delegate :retry, to: :error_resolver

    def can_restart_process?
      process.unresolved_errors.count.zero?
    end

    def target
      data[:target]
    end

    def operation
      parent if parent.is_a? RailsWorkflow::Operation
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

    def config
      RailsWorkflow.config
    end

    def error_resolver
      @error_resolver ||= config.error_resolver.new(self)
    end
  end
end
