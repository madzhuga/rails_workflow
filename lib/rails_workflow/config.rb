# frozen_string_literal: true

require 'singleton'
require 'guid'
require 'bootstrap-rails-engine'
require 'slim-rails'
require 'will_paginate'
require 'draper'
require 'sidekiq'
require 'active_model_serializers'
require 'rails_workflow/db/mysql'
require_relative './error_builder'
require_relative './error_resolver'
require_relative './process_builder'
require_relative './operation_builder'
require_relative './process_runner'
require_relative './operation_runner'
require_relative './dependency_resolver'
require_relative './process_manager'
require_relative './event_manager'
require 'rails_workflow/db/pg'

module RailsWorkflow
  # Engine configuration. Allows to set default or custom classes
  # and other engine settings.
  class Config
    include Singleton

    attr_accessor :operation_types
    attr_accessor :activejob_enabled

    def initialize # rubocop: disable Metrics/MethodLength
      init_default_operation_types
      # TODO: rework
      @default_assignment_by = %i[group role]

      @default_import_preprocessor =
        'RailsWorkflow::DefaultImporterPreprocessor'
      @default_operation_template_type = 'RailsWorkflow::OperationTemplate'
      @default_process_manager = 'RailsWorkflow::ProcessManager'
      @default_process_builder = 'RailsWorkflow::ProcessBuilder'
      @default_operation_builder = 'RailsWorkflow::OperationBuilder'
      @default_error_builder = 'RailsWorkflow::ErrorBuilder'
      @default_error_resolver = 'RailsWorkflow::ErrorResolver'
      @default_process_class = 'RailsWorkflow::Process'
      @default_process_template_type = 'RailsWorkflow::ProcessTemplate'

      @default_sql_dialect = 'pg'
      @default_process_runner = 'RailsWorkflow::ProcessRunner'
      @default_operation_runner = 'RailsWorkflow::OperationRunner'
      @default_dependency_resolver = 'RailsWorkflow::DependencyResolver'
    end

    # TODO: rework defaults

    attr_writer :sql_dialect
    def sql_dialect
      case @sql_dialect || @default_sql_dialect
      when 'pg'
        RailsWorkflow::Db::Pg
      when 'mysql'
        RailsWorkflow::Db::Mysql
      end
    end

    attr_writer :assignment_by
    def assignment_by
      @assignment_by || @default_assignment_by
    end

    def operation_types
      @default_operation_types.merge(@operation_types || {})
    end

    # TODO: fix
    def operation_template_klass=(value)
      @operation_template_type = value
    end

    attr_writer :import_preprocessor

    def import_preprocessor
      processor = @import_preprocessor || @default_import_preprocessor
      processor.constantize.new
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

    attr_writer :process_class

    def process_template_klass=(value)
      @process_template_type = value
    end

    def process_class
      @process_class || @default_process_class
    end

    def process_template_type
      @process_template_type || @default_process_template_type
    end

    def process_manager
      # Todo add custom managers support
      ProcessManager
    end

    %i[dependency_resolver operation_runner process_runner
       operation_builder process_builder error_builder error_resolver]
      .each do |key|
        instance_eval { attr_writer key }
        class_eval <<-METHOD
          def #{key}
            (@#{key} || @default_#{key}).constantize
          end
        METHOD
      end

    private

    def init_default_operation_types
      # TODO: it should allow user_role and user_group operations
      # only if user responds to necessary methods.
      @default_operation_types = {
        default:    { title: 'Default Operation',
                      class: 'RailsWorkflow::Operation' },
        event:      { title: 'Event',
                      class: 'RailsWorkflow::EventOperation' },
        user:       { title: 'User Operation',
                      class: 'RailsWorkflow::UserOperation' },
        user_role:  { title: 'Operation for User By Role',
                      class: 'RailsWorkflow::UserByRoleOperation' },
        user_group: { title: 'Operation by User Group',
                      class: 'RailsWorkflow::UserByGroupOperation' }
      }
    end
  end
end
