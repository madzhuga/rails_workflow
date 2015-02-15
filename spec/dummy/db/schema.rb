# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150215164401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "leads", force: true do |t|
    t.integer  "sales_contact_id"
    t.text     "offer"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rails_workflow_contexts", force: true do |t|
    t.integer  "parent_id"
    t.string   "parent_type"
    t.json     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_workflow_contexts", ["parent_id", "parent_type"], name: "index_rails_workflow_contexts_on_parent_id_and_parent_type", using: :btree

  create_table "rails_workflow_errors", force: true do |t|
    t.string   "message"
    t.text     "stack_trace"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "resolved"
  end

  create_table "rails_workflow_operation_templates", force: true do |t|
    t.string   "title"
    t.text     "source"
    t.text     "dependencies"
    t.string   "operation_class"
    t.integer  "process_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "async"
    t.integer  "child_process_id"
    t.integer  "assignment_id"
    t.string   "assignment_type"
    t.string   "kind"
    t.string   "role"
    t.string   "group"
    t.text     "instruction"
    t.boolean  "is_background",       default: true
    t.string   "type"
    t.string   "partial_name"
  end

  create_table "rails_workflow_operations", force: true do |t|
    t.integer  "status"
    t.boolean  "async"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "process_id"
    t.integer  "template_id"
    t.text     "dependencies"
    t.integer  "child_process_id"
    t.integer  "assignment_id"
    t.string   "assignment_type"
    t.datetime "assigned_at"
    t.string   "type"
    t.boolean  "is_active"
    t.datetime "completed_at"
    t.boolean  "is_background"
  end

  create_table "rails_workflow_process_templates", force: true do |t|
    t.string   "title"
    t.text     "source"
    t.string   "manager_class"
    t.string   "process_class"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "partial_name"
  end

  create_table "rails_workflow_processes", force: true do |t|
    t.integer  "status"
    t.boolean  "async"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "template_id"
    t.string   "type"
  end

  create_table "sales_contacts", force: true do |t|
    t.text     "message"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
