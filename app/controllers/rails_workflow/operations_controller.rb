module RailsWorkflow
  class OperationsController < ::ActionController::Base
    layout 'rails_workflow/application'
    respond_to :html

    before_action :set_operation, only: [:show, :edit, :pickup, :update, :destroy]

    before_filter do
      if @process.present?
        @processes_section_active = true
      else
        @operations_section_active = true
      end

      @current_operation = current_operation
    end

    def create
      @operation = Operation.create(permitted_params)
      redirect_to process_operation_url
    end

    def index
      @operations = OperationDecorator.decorate_collection(
          parent.try(:operations) || Operation.waiting.order(created_at: :desc)
      )

      respond_with @operations
    end

    def update
      @operation.update(permitted_params)
      redirect_to process_operation_url
    end

    def pickup
      if @operation.assign(current_user)

        set_current_operation
        redirect_to main_app.send(
                        @operation.data[:url_path],
                        *@operation.data[:url_params]
                    )
      else
        redirect_to operations_path
      end

    end

    def complete
      operation = current_operation
      if operation.present?
        operation.complete
        clear_current_operation

        redirect_to main_app.root_path
      end
    end

    def destroy
      @operation.destroy
      redirect_to process_operation_url
    end


    protected
    def permitted_params
      params.permit(
          operation: [
              :title,
              :source,
              :operation_class,
              :async,
              :is_background,
              dependencies: [:id, statuses: []]
          ]
      )[:operation]
    end


    def parent
      @parent ||= params[:process_id] && Process.find(params[:process_id])
    end

    def set_operation
      @operation ||= Operation::find(params[:id]).decorate
    end


  end
end
