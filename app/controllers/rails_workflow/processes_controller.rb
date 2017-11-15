# frozen_string_literal: true

module RailsWorkflow
  class ProcessesController < ApplicationController
    layout 'rails_workflow/application'
    respond_to :html
    before_action :set_process, only: %i[show edit update destroy]

    before_action do
      @processes_section_active = true
    end

    def index
      @processes = ProcessDecorator.decorate_collection(undecorated_collection)

      @errors = Error
                .unresolved.order(id: :asc)
                .includes(:parent).limit(10)

      @open_user_operations = OperationDecorator
                              .decorate_collection(
                                RailsWorkflow::Operation.uncompleted
                                    .unassigned.includes(:template)
                                    .limit(20)
                              )

      @statistic = {
        all: RailsWorkflow::Process.count,
        statuses: RailsWorkflow::Process.count_by_statuses
      }
    end

    def new
      @process = Process.new(permitted_params).decorate
    end

    def create
      @process = RailsWorkflow::ProcessManager.start_process(
        params[:process][:template_id], {}
      )

      redirect_to process_url(@process)
    end

    def update
      @process.update(permitted_params)
      redirect_to processes_path
    end

    def destroy
      @process.destroy
      redirect_to processes_path
    end

    protected

    def permitted_params
      params.permit(
        process: %i[
          status
          async
          title
          template_id
        ],
        filter: [:status]
      )[:process]
    end

    def undecorated_collection
      collection_scope = Process.default_scoped

      if params[:filter]
        status = Process.status_code_for(params[:filter]['status'])
        collection_scope = collection_scope.by_status(status)
      end

      collection_scope.paginate(page: params[:page]).order(id: :asc)
    end

    def set_process
      @process ||= ProcessDecorator.decorate(Process.find(params[:id])).decorate
    end
  end
end
