class AddTypeToOperationTemplate < ActiveRecord::Migration
  def change
    add_column :workflow_operation_templates, :type, :string
  end
end
