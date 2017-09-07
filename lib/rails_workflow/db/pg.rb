# frozen_string_literal: true

module RailsWorkflow
  module Db
    module Pg
      COUNT_STATUSES = <<-SQL
      select status, cnt from (
        select row_number() over (partition by status),
          count(*) over (partition by status) cnt,
          status from rails_workflow_processes)t
      where row_number = 1
      SQL
    end
  end
end
