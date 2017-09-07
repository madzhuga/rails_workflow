# frozen_string_literal: true

RailsWorkflow.setup do |config|
  # config.assignment_by = [:group, :role]

  # config.operation_types = {
  #     title: "Operation for User By Role",
  #     class: "Workflow::UserByRoleOperation"
  # }

  config.activejob_enabled = false
  # config.sql_dialect= 'mysql'
end
