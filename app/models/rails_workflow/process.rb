module RailsWorkflow
  class Process < ActiveRecord::Base
    include Status
    include Processes::DependencyResolver
    include Processes::DefaultRunner

    belongs_to :template, class_name: "RailsWorkflow::ProcessTemplate"
    has_many :operations, class_name: "RailsWorkflow::Operation"
    has_one :parent_operation, class_name: "RailsWorkflow::Operation", foreign_key: :child_process_id
    has_one :context, class_name: "RailsWorkflow::Context", as: :parent
    has_many :workflow_errors, class_name: "RailsWorkflow::Error", as: :parent

    delegate :data, to: :context
    scope :by_status, -> (status) { where(status: status) }

    def manager
      @manager ||= template.manager_class.new(self)
    end

    def self.count_by_statuses
      query = 'select status, cnt from (
                  select row_number() over (partition by status),
                    count(*) over (partition by status) cnt,
                    status from rails_workflow_processes)t
                where row_number = 1'


      statuses = connection.select_all(query).rows

      (RailsWorkflow::Process::NOT_STARTED..RailsWorkflow::Process::ROLLBACK).to_a.map{|status|
        statuses.detect{|s| s.first.to_i == status }.try(:last).to_i
      }

    end
  end
end
