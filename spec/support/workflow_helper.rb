# frozen_string_literal: true

module WorkflowHelper
  def given_a_process(workflow_identifier)
    TemplateSpecHelper.new(workflow_identifier).start
  end

  def given_current_user_role_is(_role)
    admin = create :admin
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(admin)
  end

  class TemplateSpecHelper
    attr_accessor :workflow_identifier

    def initialize(identifier)
      @workflow_identifier = identifier
    end

    def start
      import_process_template
      RailsWorkflow::ProcessManager.start_process(process_template.id, {})
    end

    def process_template
      RailsWorkflow::ProcessTemplate.find_by_title(template_title)
    end

    def template_title
      workflow_identifier.split('_').map(&:capitalize).join(' ')
    end

    def import_process_template
      processor = RailsWorkflow::ProcessImporter.new(json)
      processor.process
    end

    def json
      JSON.parse(
        File.read(
          Rails.root.join("../support/jsons/#{workflow_identifier}.json")
        )
      )
    end
  end
end
