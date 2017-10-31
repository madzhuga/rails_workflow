# frozen_string_literal: true

class CreateWorkflowProcesses < ActiveRecord::Migration
  def change
    create_tables
    create_columns
    check_json_columns
    create_indexes
  end

  def create_tables
    [
      %i[workflow_processes rails_workflow_processes],
      %i[workflow_operations rails_workflow_operations],
      %i[workflow_process_templates rails_workflow_process_templates],
      %i[workflow_operation_templates rails_workflow_operation_templates],
      %i[workflow_contexts rails_workflow_contexts],
      %i[workflow_errors rails_workflow_errors]
    ].map do |names|
      rename_table names[0], names[1] if table_exists? names[0]

      create_table names[1] unless table_exists? names[1]
    end
  end

  def create_indexes
    [
      [:rails_workflow_contexts, %i[parent_id parent_type], :rw_context_parents],
      [:rails_workflow_errors, %i[parent_id parent_type], :rw_error_parents],
      %i[rails_workflow_operation_templates process_template_id rw_ot_to_pt],
      %i[rails_workflow_operation_templates uuid rw_ot_uuids],
      %i[rails_workflow_process_templates uuid rw_pt_uuids],
      %i[rails_workflow_operations process_id rw_o_process_ids],
      %i[rails_workflow_operations template_id rw_o_template_ids]
    ].each do |idx|
      add_index idx[0], idx[1], name: idx[2] unless index_exists? idx[0], idx[1]
    end
  end

  def create_columns
    {
      rails_workflow_contexts: [
        %i[integer parent_id],
        %i[string parent_type],
        %i[text body],
        %i[datetime created_at],
        %i[datetime updated_at]
      ],

      rails_workflow_errors: [
        %i[string message],
        %i[text stack_trace],
        %i[integer parent_id],
        %i[string parent_type],
        %i[datetime created_at],
        %i[datetime updated_at],
        %i[boolean resolved]
      ],

      rails_workflow_operation_templates: [
        %i[string title],
        %i[string version],
        # [:uuid,     :uuid],
        %i[string uuid],
        %i[string tag],
        %i[text source],
        %i[text dependencies],
        %i[string operation_class],
        %i[integer process_template_id],
        %i[datetime created_at],
        %i[datetime updated_at],
        %i[boolean async],
        %i[integer child_process_id],
        %i[integer assignment_id],
        %i[string assignment_type],
        %i[string kind],
        %i[string role],
        %i[string group],
        %i[text instruction],
        %i[boolean is_background],
        %i[string type],
        %i[string partial_name]
      ],

      rails_workflow_operations: [
        %i[integer status],
        %i[boolean async],
        %i[string version],
        %i[string tag],
        %i[string title],
        %i[datetime created_at],
        %i[datetime updated_at],
        %i[integer process_id],
        %i[integer template_id],
        %i[text dependencies],
        %i[integer child_process_id],
        %i[integer assignment_id],
        %i[string assignment_type],
        %i[datetime assigned_at],
        %i[string type],
        %i[boolean is_active],
        %i[datetime completed_at],
        %i[boolean is_background]
      ],

      rails_workflow_process_templates: [
        %i[string title],
        %i[text source],
        %i[string uuid],
        %i[string version],
        %i[string tag],
        %i[string manager_class],
        %i[string process_class],
        %i[datetime created_at],
        %i[datetime updated_at],
        %i[string type],
        %i[string partial_name]
      ],

      rails_workflow_processes: [
        %i[integer status],
        %i[string version],
        %i[string tag],
        %i[boolean async],
        %i[string title],
        %i[datetime created_at],
        %i[datetime updated_at],
        %i[integer template_id],
        %i[string type]
      ]
    }.each do |table, columns|
      columns.map do |column|
        unless column_exists? table, column[1]
          add_column table, column[1], column[0]
        end
      end
    end
  end

  def check_json_columns
    [
      [RailsWorkflow::Operation, :dependencies],
      [RailsWorkflow::OperationTemplate, :dependencies],
      [RailsWorkflow::Context, :body]
    ].map do |check|
      if check[0].columns_hash[check[1].to_s].sql_type == 'json'
        # change_column check[0].table_name, check[1], "JSON USING #{check[1]}::JSON"
        change_column check[0].table_name, check[1], :text
      end
    end
  end
end
