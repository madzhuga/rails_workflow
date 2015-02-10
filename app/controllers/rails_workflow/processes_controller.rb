require 'rails_workflow/application_controller'
module RailsWorkflow
  class ProcessesController < ::InheritedResources::Base
    layout 'rails_workflow/application'

    before_filter do
      @processes_section_active = true
    end

    def create
      #any process should be build by process manager
      #using some process template.

      @process = RailsWorkflow::ProcessManager.start_process params[:process][:template_id], {}

      create! { process_url(resource) }
    end

    def update
      update! { processes_path }
    end

    def destroy
      destroy! { processes_url}
    end

    def index

      @errors = RailsWorkflow::Error.unresolved.order(id: :asc).includes(:parent).limit(10)
      @open_user_operations = RailsWorkflow::OperationDecorator.decorate_collection(
          RailsWorkflow::Operation.incompleted.unassigned.includes(:template).limit(20)
      )
      @statistic = {
          all: RailsWorkflow::Process.count,
          statuses: RailsWorkflow::Process.count_by_statuses
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
          status = ::RailsWorkflow::Process.get_status_code(params[:filter]['status'])
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
