class CreateWorkflowProcesses < ActiveRecord::Migration
  def change
    create_tables
    create_columns
    create_indexes
  end

  def create_tables
    [
        [:workflow_processes, :rails_workflow_processes],
        [:workflow_operations, :rails_workflow_operations],
        [:workflow_process_templates, :rails_workflow_process_templates],
        [:workflow_operation_templates, :rails_workflow_operation_templates],
        [:workflow_contexts, :rails_workflow_contexts],
        [:workflow_errors, :rails_workflow_errors]
    ].map do |names|
      if table_exists? names[0]
        rename_table names[0], names[1]
      end

      create_table names[1] unless table_exists? names[1]
    end

  end

  def create_indexes
    [
        [:rails_workflow_contexts, [:parent_id, :parent_type]],
        [:rails_workflow_errors, [:parent_id, :parent_type]],
        [:rails_workflow_operation_templates, :process_template_id],
        [:rails_workflow_operations, :process_id],
        [:rails_workflow_operations, :template_id]
    ].each do |idx|
      unless index_exists? idx[0], idx[1]
        add_index idx[0], idx[1]
      end
    end
  end

  def create_columns
    {
      :rails_workflow_contexts => [
        [:integer,  :parent_id],
        [:string,   :parent_type],
        [:json,     :body],
        [:datetime, :created_at],
        [:datetime, :updated_at],
      ],

      :rails_workflow_errors => [
        [:string,   :message],
        [:text,    :stack_trace],
        [:integer,  :parent_id],
        [:string,   :parent_type],
        [:datetime, :created_at],
        [:datetime, :updated_at],
        [:boolean,  :resolved]
      ],

      :rails_workflow_operation_templates => [
          [:string,   :title],
          [:text,     :source],
          [:text,     :dependencies],
          [:string,   :operation_class],
          [:integer,  :process_template_id],
          [:datetime, :created_at],
          [:datetime, :updated_at],
          [:boolean,  :async],
          [:integer,  :child_process_id],
          [:integer,  :assignment_id],
          [:string,   :assignment_type],
          [:string,   :kind],
          [:string,   :role],
          [:string,   :group],
          [:text,     :instruction],
          [:boolean,  :is_background],
          [:string,   :type],
          [:string,   :partial_name],
      ],

      :rails_workflow_operations => [
          [:integer,  :status],
          [:boolean,  :async],
          [:string,   :title],
          [:datetime, :created_at],
          [:datetime, :updated_at],
          [:integer,  :process_id],
          [:integer,  :template_id],
          [:text,     :dependencies],
          [:integer,  :child_process_id],
          [:integer,  :assignment_id],
          [:string,   :assignment_type],
          [:datetime, :assigned_at],
          [:string,   :type],
          [:boolean,  :is_active],
          [:datetime, :completed_at],
          [:boolean,  :is_background]
      ],

      :rails_workflow_process_templates => [
          [:string,   :title],
          [:text,     :source],
          [:string,   :manager_class],
          [:string,   :process_class],
          [:datetime, :created_at],
          [:datetime, :updated_at],
          [:string,   :type],
          [:string,   :partial_name]
      ],

      :rails_workflow_processes => [
          [:integer,  :status],
          [:boolean,  :async],
          [:string,   :title],
          [:datetime, :created_at],
          [:datetime, :updated_at],
          [:integer,  :template_id],
          [:string,   :type]
      ]
    }.each do |table, columns|
      columns.map do |column|
        unless column_exists? talbe, column[1]
          add_column table, column[1], column[0]
        end
      end

    end

  end
end
