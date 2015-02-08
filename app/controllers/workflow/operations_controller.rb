require_dependency "workflow/application_controller"

module Workflow
  class OperationsController < ::InheritedResources::Base
    layout 'workflow/application'

    before_filter do
      if parent.present?
        @processes_section_active = true
      else
        @operations_section_active = true
      end

      @current_operation = current_operation
    end


    defaults collection_name: 'operations', resource_class: Operation
    belongs_to :process, optional: true

    def create
      create!{ process_operation_url }
    end


    def update
      @operation = Workflow::Operation.find(params[:id])
      update! { process_operation_url }
    end

    def pickup
      @operation = Workflow::Operation.find(params[:id])

      if @operation.assign(current_user)
        set_current_operation
        redirect_to main_app.send(@operation.data[:url_path], *@operation.data[:url_params])
      else
        redirect_to operations_path
      end

    end

    def complete
      operation = current_operation
      if operation.present?
        operation.complete
        clear_current_operation

        # redirect_to root_path #where to redirect on operation complete??
      end
    end

    def destroy
      destroy! { process_operation_url}
    end


    protected
    def permitted_params
      params.permit(operation: [:title, :source, :operation_class, :async, :is_background, dependencies: [:id, statuses: []]])
    end

    def operations_collection
      get_collection_ivar ||
          set_collection_ivar(
              end_of_association_chain.waiting.order(created_at: :desc)
          )
    end

    def collection
      if parent.present?
        OperationDecorator.decorate_collection(super)
      else
        scope = operations_collection
        OperationDecorator.decorate_collection(scope)
      end
    end

    def resource
      @operation ||= Operation::find(params[:id]).decorate
    end


  end
end
