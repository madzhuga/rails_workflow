# frozen_string_literal: true

module RailsWorkflow
  RSpec.shared_context 'process template with events' do
    let!(:template) { prepare_template }

    let(:process) { ProcessManager.create_process template.id, some: 'value' }
    let(:operation_runner) { RailsWorkflow::OperationRunner }
    let(:process_manager) { RailsWorkflow::ProcessManager.new process }

    def prepare_template_operations(template)
      operation = create :user_operation_template, process_template: template
      event = create :event, tag: 'first_event', process_template: template

      template_options = {
        process_template: template,
        dependencies: prepare_template_dependencies(operation, event)
      }

      # second event
      create :event, template_options.merge(tag: 'second_event')
      create :user_operation_template, template_options
    end

    def prepare_template_dependencies(operation, event)
      [{ 'id' => operation.id, 'statuses' => [RailsWorkflow::Status::DONE] },
       { 'id' => event.id, 'statuses' => [RailsWorkflow::Status::DONE] }]
    end

    def prepare_template
      template = create :process_template
      prepare_template_operations(template)
      template
    end
  end
end
