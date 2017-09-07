# frozen_string_literal: true

class CreateSalesContacts < ActiveRecord::Migration
  def change
    create_table :sales_contacts do |t|
      t.text :message
      t.string :email

      t.timestamps
    end
  end
end
