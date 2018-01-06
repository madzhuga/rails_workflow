# frozen_string_literal: true

class CreateLeads < ActiveRecord::Migration[4.2]
  def change
    create_table :leads do |t|
      t.integer :sales_contact_id
      t.text :offer
      t.string :name

      t.timestamps
    end
  end
end
