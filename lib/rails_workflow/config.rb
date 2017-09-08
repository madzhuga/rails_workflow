# frozen_string_literal: true

# TODO: check if we really need all those
require 'singleton'
require 'guid'
require 'bootstrap-rails-engine'
require 'slim-rails'
require 'will_paginate'
require 'draper'
require 'sidekiq'
require 'active_model_serializers'
require 'rails_workflow/db/mysql'
require_relative './error_manager'
require_relative './process_builder'
require_relative './operation_builder'
require_relative './process_runner'
require_relative './operation_runner'
require 'rails_workflow/db/pg'

module RailsWorkflow
  # Engine configuration. Allows to set default or custom classes
  # and other engine settings.
  class Config
    include Singleton

    attr_accessor :operation_types
    attr_accessor :activejob_enabled

    def initialize
      init_default_operation_types
      @default_import_preprocessor =
        'RailsWorkflow::DefaultImporterPreprocessor'

      @default_operation_template_type = 'RailsWorkflow::OperationTemplate'
      @default_process_manager = 'RailsWorkflow::ProcessManager'
      @default_process_builder = 'RailsWorkflow::ProcessBuilder'
      @default_operation_builder = 'RailsWorkflow::OperationBuilder'
      @default_error_manager = 'RailsWorkflow::ErrorManager'
      @default_process_class = 'RailsWorkflow::Process'
      @default_process_template_type = 'RailsWorkflow::ProcessTemplate'
      @default_assignment_by = %i[group role]
      @default_sql_dialect = 'pg'
      @default_process_runner = 'RailsWorkflow::ProcessRunner'
      @default_operation_runner = 'RailsWorkflow::OperationRunner'
    end

    def sql_dialect
      case @sql_dialect || @default_sql_dialect
      when 'pg'
        RailsWorkflow::Db::Pg
      when 'mysql'
        RailsWorkflow::Db::Mysql
      end
    end

    attr_writer :sql_dialect

    def assignment_by
      @assignment_by || @default_assignment_by
    end

    attr_writer :assignment_by

    def operation_types
      @default_operation_types.merge(@operation_types || {})
    end

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

    attr_writer :error_manager

    def error_manager
      (@error_manager || @default_error_manager).constantize
    end

    attr_writer :process_builder
    def process_builder
      (@process_builder || @default_process_builder).constantize
    end

    attr_writer :operation_builder
    def operation_builder
      (@operation_builder || @default_operation_builder).constantize
    end

    attr_writer :process_runner
    def process_runner
      (@process_runner || @default_process_runner).constantize
    end

    attr_writer :operation_runner
    def operation_runner
      (@operation_runner || @default_operation_runner).constantize
    end

    private

    def init_default_operation_types
      @default_operation_types = {
        default:    { title: 'Default Operation',
                      class: 'RailsWorkflow::Operation' },
        user_role:  { title: 'Operation for User By Role',
                      class: 'RailsWorkflow::UserByRoleOperation' },
        user_group: { title: 'Operation by User Group',
                      class: 'RailsWorkflow::UserByGroupOperation' }
      }
    end
  end
end
