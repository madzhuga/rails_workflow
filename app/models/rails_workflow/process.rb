# frozen_string_literal: true

module RailsWorkflow
  # Process stores service information including links to process template,
  # all operations, parent operation, context etc.
  class Process < ActiveRecord::Base
    include Status
    include HasContext

    belongs_to :template, class_name: 'RailsWorkflow::ProcessTemplate'
    has_many :operations, class_name: 'RailsWorkflow::Operation'
    delegate :events, to: :operations, allow_nil: true

    has_one :parent_operation,
            class_name: 'RailsWorkflow::Operation',
            foreign_key: :child_process_id

    alias parent parent_operation
    has_many :workflow_errors, class_name: 'RailsWorkflow::Error', as: :parent

    delegate :data, to: :context
    scope :by_status, ->(status) { where(status: status) }

    def manager
      @manager ||= template.manager_class.new(self)
    end

    def self.count_by_statuses
      query = RailsWorkflow.config.sql_dialect::COUNT_STATUSES

      statuses = connection.select_all(query).rows

      statuses_array.map do |status|
        statuses.detect { |s| s.first.to_i == status }.try(:last).to_i
      end
    end

    def self.statuses_array
      (NOT_STARTED..ROLLBACK).to_a
    end

    def uncompleted?
      uncompleted_statuses.include?(status) &&
        uncompleted_operations.reject(&:async).size.zero?
    end

    # Returns set or operation that not yet completed.
    # Operation complete in DONE, SKIPPED, CANCELED, etc many other statuses
    def uncompleted_operations
      operations.reject(&:completed?)
    end

    def can_start?
      [Status::NOT_STARTED, Status::IN_PROGRESS]
        .include?(status) && !operations.empty?
    end

    def unresolved_errors
      workflow_errors.unresolved.where.not(id: id)
    end

    def complete
      self.status = Status::DONE
      save
    end
  end
end
