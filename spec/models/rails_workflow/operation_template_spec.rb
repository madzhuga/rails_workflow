# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe OperationTemplate, type: :model do
    let(:template) { create :process_template }

    it 'should create operation template of a given type' do
      expect do
        OperationTemplate
          .create!(
            title: 'First Test project',
            process_template_id: template.id,
            type: 'RailsWorkflow::CustomOperationTemplate'
          )
      end.to change(RailsWorkflow::CustomOperationTemplate, :count).by(1)
    end

    it 'should return only independent operations' do
      operation = create :operation_template, process_template: template

      dependencies = [
        {
          'id' => operation.id,
          'statuses' => [Status::DONE]
        }
      ]

      create :operation_template,
             process_template: template,
             dependencies: dependencies
      expect(RailsWorkflow::OperationTemplate.independent_only.to_a).to match_array([operation])
    end
  end
end
