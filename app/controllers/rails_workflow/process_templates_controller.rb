# frozen_string_literal: true

module RailsWorkflow
  class ProcessTemplatesController < ApplicationController
    layout 'rails_workflow/application'
    respond_to :html, :json

    before_action :set_process_template, only: %i[show edit update destroy]

    before_action do
      @config_section_active = true
    end

    def upload
      uploaded = params[:import_file]

      json = JSON.parse(uploaded.read)

      importer = RailsWorkflow::ProcessImporter.new(json)
      importer.process

      redirect_to process_templates_path
    end

    def export
      template = ProcessTemplate.find(params[:id])
      send_data render_to_string(json: template, serializer: ProcessTemplateSerializer), filename: "#{template.title}.json"
    end

    def index
      @process_templates = ProcessTemplateDecorator
                           .decorate_collection(process_templates_collection)

      respond_with(@process_templates)
    end

    def new
      @process_template = ProcessTemplate.new(permitted_params).decorate
      respond_with @process_template
    end

    def create
      @process_template = ProcessTemplate.create(permitted_params)
      redirect_to process_template_operation_templates_path(@process_template)
    end

    def update
      @process_template.update(permitted_params)
      redirect_to process_template_url(@process_template)
    end

    def destroy
      @process_template.destroy
      redirect_to process_templates_url
    end

    protected

    def permitted_params
      params.permit(
        process_template: %i[
          title
          source
          manager_class
          partial_name
          process_class
          type
        ]
      )[:process_template]
    end

    def set_process_template
      @process_template = ProcessTemplate.find(params[:id]).decorate
    end

    def process_templates_collection
      ProcessTemplate
        .order(id: :desc)
    end
  end
end
