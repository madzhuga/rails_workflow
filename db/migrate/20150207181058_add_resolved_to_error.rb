class AddResolvedToError < ActiveRecord::Migration
  def change
    add_column :workflow_errors, :resolved, :boolean
  end
end
