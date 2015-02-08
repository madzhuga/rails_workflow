class CreateWorkflowWfProcesses < ActiveRecord::Migration
  def change
    create_table :workflow_processes do |t|
      t.integer :status
      t.boolean :async
      t.string :title

      t.timestamps
    end

    create_table :workflow_operations do |t|
      t.integer :status
      t.boolean :async
      t.string :title

      t.timestamps
    end

    create_table :workflow_process_templates do |t|
      t.string :title
      t.text :source
      t.string :manager_class
      t.string :process_class

      t.timestamps
    end

    create_table :workflow_operation_templates do |t|
      t.string :title
      t.text :source
      t.text :dependencies
      t.string :operation_class
      t.integer :process_template_id
      t.timestamps
    end


    add_column :workflow_processes, :template_id, :integer
    add_column :workflow_processes, :type, :string
    add_column :workflow_operations, :process_id, :integer
    add_column :workflow_operations, :template_id, :integer
    add_column :workflow_operation_templates, :async, :boolean
    add_column :workflow_operations, :dependencies, :text
    add_column :workflow_operation_templates, :child_process_id, :integer
    add_column :workflow_operations, :child_process_id, :integer

    add_column :workflow_operation_templates, :assignment_id, :integer
    add_column :workflow_operation_templates, :assignment_type, :string

    add_column :workflow_operations, :assignment_id, :integer
    add_column :workflow_operations, :assignment_type, :string
    add_column :workflow_operations, :assigned_at, :datetime

    add_column :workflow_operation_templates, :kind, :string

    add_column :workflow_operation_templates, :role, :string
    add_column :workflow_operation_templates, :group, :string

    add_column :workflow_operations, :type, :string
    add_column :workflow_operations, :is_active, :boolean
    add_column :workflow_operation_templates, :instruction, :text

    create_table :workflow_contexts do |t|
      t.integer :parent_id
      t.string :parent_type
      t.json :body

      t.timestamps
    end

    add_index :workflow_contexts, [:parent_id, :parent_type]

    create_table :workflow_errors do |t|
      t.string :message
      t.text :stack_trace
      t.integer :parent_id
      t.string :parent_type

      t.timestamps
    end

    add_column :workflow_operations, :completed_at, :datetime
    add_column :workflow_operation_templates, :is_background, :boolean, default: true
    add_column :workflow_operations, :is_background, :boolean


  end
end
