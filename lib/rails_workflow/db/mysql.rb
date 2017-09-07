# frozen_string_literal: true

module RailsWorkflow
  module Db
    module Mysql
      COUNT_STATUSES = <<-SQL
      SELECT status, cnt FROM
               (
                    SELECT @row_number:=CASE
                                            WHEN @status=status THEN @row_number+1
                                            ELSE 1
                                        END AS row_number,
                           cnt,
                           @status:=status as status
                    FROM
                      ( SELECT count(*) AS cnt,
                               a.status
                        FROM rails_workflow_processes a
                        LEFT JOIN rails_workflow_processes b ON a.status=b.status
                        GROUP BY a.status,a.id
                      ) tmp,
                      (SELECT @row_number:=0,@status:=-1) AS t
               ) t1 WHERE row_number = 1
      SQL
    end
  end
end
