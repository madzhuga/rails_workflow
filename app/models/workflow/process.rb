module Workflow
  class Process < ActiveRecord::Base
    include ProcessStatus
    include Processes::DependencyResolver
    include Processes::DefaultRunner

    belongs_to :template, class_name: 'Workflow::ProcessTemplate'
    has_many :operations, class_name: 'Workflow::Operation'
    has_one :parent_operation, class_name: 'Workflow::Operation', foreign_key: :child_process_id
    has_one :context, class_name: 'Workflow::Context', as: :parent
    has_many :workflow_errors, class_name: "Workflow::Error", as: :parent

    delegate :data, to: :context
    scope :by_status, -> (status) { where(status: status) }

    def manager
      @manager ||= template.manager_class.new(self)
    end

    def self.count_by_statuses
      query = 'select status, cnt from (
                  select row_number() over (partition by status),
                    count(*) over (partition by status) cnt,
                    status from workflow_processes)t
                where row_number = 1'


      statuses = connection.select_all(query).rows

      (Workflow::Process::NOT_STARTED..Workflow::Process::ROLLBACK).to_a.map{|status|
        statuses.detect{|s| s.first.to_i == status }.try(:last).to_i
      }

    end
  end
end
