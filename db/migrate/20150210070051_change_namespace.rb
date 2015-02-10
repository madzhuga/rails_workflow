class ChangeNamespace < ActiveRecord::Migration
  def change
    rename_table :workflow_processes, :rails_workflow_processes
    rename_table :workflow_operations, :rails_workflow_operations
    rename_table :workflow_process_templates, :rails_workflow_process_templates
    rename_table :workflow_operation_templates, :rails_workflow_operation_templates
    rename_table :workflow_contexts, :rails_workflow_contexts
    rename_table :workflow_errors, :rails_workflow_errors
  end
end
