require "workflow/engine"
require 'singleton'
require 'inherited_resources'
require 'devise'
require 'draper'


module Workflow

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
              class: "Workflow::Operation"
          },
          user_role: {
              title: "Operation for User By Role",
              class: "Workflow::UserByRoleOperation"
          },
          user_group: {
              title: "Operation by User Group",
              class: "Workflow::UserByGroupOperation"
          }
      }

      @default_operation_template_type = "Workflow::OperationTemplate"
      @default_process_manager = "Workflow::ProcessManager"
      @default_process_class = "Workflow::Process"
      @default_process_template_type = "Workflow::ProcessTemplate"
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

    def default_operation_template_type
      @default_operation_template_type
    end

    def manager_class
      @default_process_manager
    end

    def process_class
      @default_process_class
    end

    def process_template_type
      @default_process_template_type
    end



  end


  def self.setup
    yield self.config
  end
end
