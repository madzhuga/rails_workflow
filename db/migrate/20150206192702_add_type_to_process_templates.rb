class AddTypeToProcessTemplates < ActiveRecord::Migration
  def change
    add_column :workflow_process_templates, :type, :string
  end
end
