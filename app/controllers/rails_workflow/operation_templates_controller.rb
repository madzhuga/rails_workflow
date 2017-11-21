# frozen_string_literal: true

module RailsWorkflow
  # Used in configuration UI to CRUD operation templates
  class OperationTemplatesController < ApplicationController
    layout 'rails_workflow/application'
    before_action :set_operation_template, only: %i[show edit update destroy]
    before_action :set_process_template
    respond_to :html

    before_action do
      @config_section_active = true
    end

    def index
      @operation_templates =
        OperationTemplateDecorator
        .decorate_collection(operation_templates_collection)
    end

    def new
      @operation_template = OperationTemplate.new(permitted_params).decorate
      @operation_template.process_template = @process_template
    end

    def create
      @operation_template =
        @process_template.operations.create(permitted_params)

      redirect_to process_template_operation_templates_url
    end

    def update
      @operation_template.update(permitted_params)
      redirect_to process_template_operation_templates_url
    end

    def destroy
      @operation_template.destroy
      redirect_to process_template_operation_templates_url
    end

    protected

    def permitted_attributes
      [
        :kind, :type, :tag, :instruction, :title,
        :source, :multiple, :child_process_id,
        :operation_class, :role, :partial_name, :async,
        :is_background, :group,
        dependencies: [:id, statuses: []]
      ]
    end

    def permitted_params
      parameters = params.permit(operation_template: permitted_attributes)

      if parameters[:operation_template].present?
        parameters[:operation_template][:dependencies] =
          prepare_dependencies parameters[:operation_template]
      end

      parameters[:operation_template]
    end

    def prepare_dependencies(parameters)
      parameters[:dependencies] &&
        parse_dependencies(parameters[:dependencies].to_hash)
    end

    def parse_dependencies(hash)
      hash.values.each do |dep|
        dep['id'] = dep['id'].to_i
        dep['statuses'] = dep['statuses'].map(&:to_i) ||
                          RailsWorkflow::OperationTemplate.all_statuses
      end
    end

    def operation_templates_collection
      @operation_templates = @process_template.try(:operations) ||
                             OperationTemplate.order(id: :asc)
    end

    def set_process_template
      @process_template = ProcessTemplate
                          .find(params[:process_template_id]).decorate
    end

    def set_operation_template
      @operation_template ||= OperationTemplate.find(params[:id]).decorate
    end
  end
end
