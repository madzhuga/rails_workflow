require 'workflow/application_controller'
module Workflow
  class ProcessesController < ::InheritedResources::Base
    layout 'workflow/application'

    before_filter do
      @processes_section_active = true
    end

    def create
      #any process should be build by process manager
      #using some process template.

      @process = Workflow::ProcessManager.start_process params[:process][:template_id], {}

      create! { process_url(resource) }
    end

    def update
      update! { processes_path }
    end

    def destroy
      destroy! { processes_url}
    end

    def index

      @errors = Workflow::Error.unresolved.order(id: :asc).includes(:parent).limit(10)
      @open_user_operations = Workflow::OperationDecorator.decorate_collection(
          Workflow::Operation.incompleted.unassigned.includes(:template).limit(20)
      )
      @statistic = {
          all: Workflow::Process.count,
          statuses: Workflow::Process.count_by_statuses
      }

      index!
    end


    protected
    def permitted_params
      params.permit(processes: [:status, :async, :title, :template_id], filter: [:status])
    end

    def undecorated_collection
      get_collection_ivar || begin
        collection_scope = end_of_association_chain

        if params[:filter]
          status = ::Workflow::Process.get_status_code(params[:filter]['status'])
          collection_scope = collection_scope.by_status(status)
        end

        set_collection_ivar collection_scope.paginate(page: params[:page]).order(created_at: :desc)

      end
    end


    def collection
      ProcessDecorator.decorate_collection(undecorated_collection)
    end

    def resource
      ProcessDecorator.decorate(super)
    end


  end
end
