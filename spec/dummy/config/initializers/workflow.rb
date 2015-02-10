RailsWorkflow.setup do |config|

  # config.assignment_by = [:group, :role]

  # config.operation_types = {
  #     title: "Operation for User By Role",
  #     class: "Workflow::UserByRoleOperation"
  # }

  config.sidekiq_enabled = false

end
