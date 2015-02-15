class AddPartialNameToContext < ActiveRecord::Migration
  def change
    add_column :rails_workflow_operation_templates, :partial_name, :string
    add_column :rails_workflow_process_templates, :partial_name, :string
  end
end
