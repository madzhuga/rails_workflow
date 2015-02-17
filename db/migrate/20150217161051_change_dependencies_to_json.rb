class ChangeDependenciesToJson < ActiveRecord::Migration
  def change
    change_column :rails_workflow_operation_templates, :dependencies, 'JSON USING dependencies::JSON'
    change_column :rails_workflow_operations, :dependencies, 'JSON USING dependencies::JSON'
  end
end
