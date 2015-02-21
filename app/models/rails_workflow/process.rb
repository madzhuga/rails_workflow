module RailsWorkflow

  # According to http://en.wikipedia.org/wiki/Workflow_engine workflow engine is a software
  # application that manages business processes.
  #
  # Process is a set of operations. Process Manager buildling process using process template and creating operations
  # which has no dependencies on other operations and can be build. When some operation is changing status, process
  # building new operations. If all operations is completed (done, canceled, etc) - process is done.
  #
  # Here you can see process example:
  #
  # http://madzhuga.github.io/rails_workflow/images/default_operation_template.png
  #
  # Rails Workflow Engine UI lets you track and manage processes. As you can see on a screenshot UI shows process
  # configuration information, context, already existing process operations (with status, date of creation and completion
  # assignment etc). It also shows you information about not yet created operations for this process and shows dependencies
  # of that operations.
  #
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

    # @return [RailsWorkflow::ProcessManager]
    def manager
      @manager ||= template.manager_class.new(self)
    end

    # @private
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
