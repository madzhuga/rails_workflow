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
          Workflow::Operation.user_ready_statuses.include? @current_workflow_operation.status

        @current_workflow_operation

      else

        @current_workflow_operation = begin

          if Workflow::Operation.exists?(id: operation_id, status: Workflow::Operation::WAITING)
            operation = Workflow::Operation.find(operation_id)
            Workflow::OperationHelperDecorator.decorate(operation)
          else
            clear_current_operation
          end

        end
      end
    end

  end
  helper_method :current_operation

  def available_operations
    operations = Workflow::Operation.available_for_user(current_user)
    Workflow::OperationHelperDecorator.decorate_collection(operations)
  end
  helper_method :available_operations

  def assigned_operations
    operations = Workflow::Operation.assigned_to(current_user).waiting
    Workflow::OperationHelperDecorator.decorate_collection(operations)
  end
  helper_method :assigned_operations


end
