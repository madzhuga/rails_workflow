# frozen_string_literal: true

module RailsWorkflow
  class ProcessTemplate < ActiveRecord::Base
    include RailsWorkflow::Uuid
    has_many :operations,
             -> { order(id: :asc) },
             class_name: 'OperationTemplate'

    def other_processes
      ProcessTemplate.where.not(id: id)
    end

    # we try to read process class from template
    # and set default Workflow::Process if blank process_class on template
    def process_class
      get_class_for :process_class,
                    RailsWorkflow.config.process_class
    end

    def manager_class
      get_class_for(:manager_class,
                    RailsWorkflow.config.manager_class)
    end

    def independent_operations
      operations.independent_only.to_a
    end

    # here we calculate template operations that depends on
    # given process operation status and template id
    def dependent_operations(operation)
      operations.select do |top|
        top.dependencies.select do |dp|
          dp['id'] == operation.template.id &&
            dp['statuses'].include?(operation.status)
        end.present?
      end
    end

    private

    # we try to read manager class from process template
    # otherwise use default

    def get_class_for(symb, default)
      (read_attribute(symb).presence || default).constantize
    end
  end
end
