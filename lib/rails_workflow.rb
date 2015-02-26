require "rails_workflow/engine"
require 'singleton'
require 'inherited_resources'
require 'devise'
require 'draper'


module RailsWorkflow

  def self.config
    Config.instance
  end

  class Config
    include Singleton

    attr_accessor :operation_types
    attr_accessor :sidekiq_enabled

    def initialize
      @default_operation_types = {
          default: {
              title: "Default Operation",
              class: "RailsWorkflow::Operation"
          },
          user_role: {
              title: "Operation for User By Role",
              class: "RailsWorkflow::UserByRoleOperation"
          },
          user_group: {
              title: "Operation by User Group",
              class: "RailsWorkflow::UserByGroupOperation"
          }
      }

      @default_operation_template_type = "RailsWorkflow::OperationTemplate"
      @default_process_manager = "RailsWorkflow::ProcessManager"
      @default_process_class = "RailsWorkflow::Process"
      @default_process_template_type = "RailsWorkflow::ProcessTemplate"
      @default_assignment_by = [:group, :role]


    end

    def assignment_by
      @assignment_by || @default_assignment_by
    end

    def assignment_by=(assignment)
      @assignment_by = assignment
    end

    def operation_types
      @default_operation_types.merge(@operation_types || {})
    end

    def operation_template_klass=(value)
      @operation_template_type = value
    end

    def default_operation_template_type
      @operation_template_type || @default_operation_template_type
    end

    def manager_class=(value)
      @process_manager = value
    end

    def manager_class
      @process_manager || @default_process_manager
    end

    def process_class=(value)
      @process_class = value
    end

    def process_template_klass=(value)
      @process_template_type = value
    end

    def process_class
      @process_class || @default_process_class
    end

    def process_template_type
      @process_template_type || @default_process_template_type
    end

  end


  def self.setup
    yield self.config
  end
end
