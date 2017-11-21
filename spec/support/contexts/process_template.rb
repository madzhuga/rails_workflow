# frozen_string_literal: true

RSpec.shared_context 'process template' do
  def prepare_template_operations(template)
    operation = create :operation_template, process_template: template

    template_options = {
      process_template: template,
      dependencies: prepare_template_dependencies(operation)
    }
    create :operation_template, template_options
  end

  def prepare_template_dependencies(operation)
    [{
      'id' => operation.id,
      'statuses' => [RailsWorkflow::Status::DONE]
    }]
  end

  def prepare_template
    template = create :process_template
    prepare_template_operations(template)
    template
  end
end
