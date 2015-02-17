require 'rails_workflow/application_controller'
module RailsWorkflow
  class OperationTemplatesController < ::InheritedResources::Base
    layout 'rails_workflow/application'


    defaults collection_name: 'operations', resource_class: OperationTemplate
    belongs_to :process_template

    before_filter do
      @config_section_active = true
    end

    def new
      @operation_template = OperationTemplate.new(permitted_params[:operation_template]).decorate
      @operation_template.process_template = parent
      new!
    end

    def create
      create!{ process_template_operation_templates_url }
    end

    def update
      @operation_template = RailsWorkflow::OperationTemplate.find(params[:id])
      update! { process_template_operation_templates_url }
    end

    def destroy
      destroy! { process_template_operation_templates_url}
    end


    protected
    def permitted_params
      parameters =
          params.permit(
          operation_template: [
              :kind,
              :type,
              :instruction,
              :title, :source,
              :child_process_id,
              :operation_class,
              :role,
              :partial_name,
              :async,
              :is_background,
              :group,
              dependencies: [
                  :id,
                  statuses: []
              ]
          ])

      if parameters[:operation_template].present?
        parameters[:operation_template][:dependencies] =
            prepare_dependencies parameters[:operation_template]
      end

      parameters
    end

    def prepare_dependencies parameters
      if parameters && parameters[:dependencies].present?
        parse_dependencies parameters[:dependencies].to_hash
      end
    end

    def parse_dependencies hash
      hash.values.each do |dep|
        dep['id'] = dep['id'].to_i
        dep['statuses'] = dep['statuses'].map(&:to_i) || RailsWorkflow::OperationTemplate.all_statuses
      end
    end

    def operations_collection
      get_collection_ivar || begin
        # collection_scope = Workflow::OperationTemplate.select("")
        collection_scope = end_of_association_chain
        set_collection_ivar collection_scope.order(id: :asc)

      end
    end

    def collection
      OperationTemplateDecorator.decorate_collection(operations_collection)
    end

    def resource
      @operation_template ||= OperationTemplate::find(params[:id]).decorate
    end
  end
end
