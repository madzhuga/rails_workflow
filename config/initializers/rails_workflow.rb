# frozen_string_literal: true

class ActionController::Base
  def set_current_operation
    session[:current_operation_id] = @operation.id
  end

  def clear_current_operation
    session[:current_operation_id] = nil
  end

  def current_operation
    if session[:current_operation_id].present?
      operation_id = session[:current_operation_id]

      if @current_workflow_operation &&
         @current_workflow_operation.id == operation_id
        RailsWorkflow::Operation.user_ready_statuses.include? @current_workflow_operation.status

        @current_workflow_operation

      else

        @current_workflow_operation = begin
          if RailsWorkflow::Operation.exists?(id: operation_id, status: RailsWorkflow::Status::WAITING)
            operation = RailsWorkflow::Operation.find(operation_id)
            RailsWorkflow::OperationHelperDecorator.decorate(operation)
          else
            clear_current_operation
          end
        end
      end
    end
  end

  helper_method :current_operation

  def available_operations
    operations = RailsWorkflow::Operation.available_for_user(current_user)
    RailsWorkflow::OperationHelperDecorator.decorate_collection(operations)
  end
  helper_method :available_operations

  def assigned_operations
    operations = RailsWorkflow::Operation.assigned_to(current_user).waiting
    RailsWorkflow::OperationHelperDecorator.decorate_collection(operations)
  end

  helper_method :assigned_operations
end
