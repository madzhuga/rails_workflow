require "rails_workflow/engine"
require 'singleton'
require 'inherited_resources'
require 'devise'
require 'draper'


module RailsWorkflow

  # @private
  def self.config
    Config.instance
  end

  #
  # If you want to change some settings, add config/initializers/rails_workflow.rb
  # to your application:
  #
  #   RailsWorkflow.setup do |config|
  #   ...
  #   end
  #
  class Config


    include Singleton

    # @private
    attr_accessor :operation_types

    # @private
    attr_accessor :sidekiq_enabled

    # @private
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

    # @private
    def assignment_by
      @assignment_by || @default_assignment_by
    end

    # User operations can be assigned to users using user's role or group.
    # By default you can use both - group or role. Or you can specify
    # other criteria
    #
    #   RailsWorkflow.setup do |config|
    #     ...
    #     config.assignment_by = [:group, :role]
    #     ...
    #   end

    def assignment_by=(assignment)
      @assignment_by = assignment
    end

    # @private
    def operation_types
      @default_operation_types.merge(@operation_types || {})
    end

    # By default configuration using RailsWorkflow::OperationTemplate for new operation templates.
    # You can specify some other custom default class:
    #
    #   RailsWorkflow.setup do |config|
    #     ...
    #     config.operation_template_klass = "RailsWorkflow::OperationTemplate"
    #     ...
    #   end

    def operation_template_klass=(value)
      @operation_template_type = value
    end

    # @private
    def default_operation_template_type
      @operation_template_type || @default_operation_template_type
    end

    # ProcessManager responsible for building, starting and completing processes. ProcessTemplate
    # allow you to specify custom process manager.
    #
    # By default configuration using RailsWorkflow::ProcessManager for processes.
    # You can specify some other custom default class:
    #
    #   RailsWorkflow.setup do |config|
    #     ...
    #     config.manager_class = "RailsWorkflow::ProcessManager"
    #     ...
    #   end
    def manager_class=(value)
      @process_manager = value
    end

    # @private
    def manager_class
      @process_manager || @default_process_manager
    end

    # Process class is responsible for process behaviour. By default process templates
    # uses RailsWorkflow::Process. You can specify some other custom default class:
    #
    #   RailsWorkflow.setup do |config|
    #     ...
    #     config.process_class = "RailsWorkflow::Process"
    #     ...
    #   end
    def process_class=(value)
      @process_class = value
    end


    # Process template is responsible for building process and operations. You can specify
    # custom process template class for process configuration. By default configuration using
    # RailsWorkflow::ProcessTemplate for process templates.
    # Here you can specify some other custom default class:
    #
    #   RailsWorkflow.setup do |config|
    #     ...
    #     config.process_template_klass = "RailsWorkflow::ProcessTemplate"
    #     ...
    #   end
    #
    # @see RailsWorkflow::ProcessTemplates::DefaultBuilder

    def process_template_klass=(value)
      @process_template_type = value
    end

    # @private
    def process_class
      @process_class || @default_process_class
    end

    # @private
    def process_template_type
      @process_template_type || @default_process_template_type
    end

    # Used to enable/disable sidekiq in engine:
    #
    #   RailsWorkflow.setup do |config|
    #     config.sidekiq_enabled = false
    #   end
    #
    #
    def sidekiq_enabled=(value)
      @sidekiq_enabled = value
    end

  end


  # Used to configure Rails Workflow Engine. Add to config/initializers/workflow.rb:
  #
  #   RailsWorkflow.setup do |config|
  #     config.sidekiq_enabled = false
  #   end
  #
  # @see RailsWorkflow::Config
  #
  def self.setup
    yield self.config
  end
end
