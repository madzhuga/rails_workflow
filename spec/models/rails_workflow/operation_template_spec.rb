require 'rails_helper'

module RailsWorkflow
  RSpec.describe OperationTemplate, :type => :model do

    let(:template) { create :process_template }

    it 'should create operation template of a given type' do
      operation_template = OperationTemplate.
          create! (
                      {
                          title: 'First Test project',
                          process_template_id: template.id,
                          type: "RailsWorkflow::CustomOperationTemplate"
                      }
                  )
      expect(operation_template).to be_instance_of(RailsWorkflow::CustomOperationTemplate)
    end

    it 'should return only independent operations' do
      operation = create :operation_template, process_template: template

      dependencies = [
          {
              "id" => operation.id,
              "statuses" => [RailsWorkflow::Operation::DONE]
          }
      ]

      create :operation_template, process_template: template, dependencies: dependencies
      expect(RailsWorkflow::OperationTemplate.independent_only.to_a).to match_array([operation])
    end


    def dependencies=(dependencies)
      write_attribute(:dependencies, dependencies.to_json.to_s)
    end

    def dependencies
      value = read_attribute(:dependencies)
      if value.present?
        JSON.parse(value)
      else
        []
      end
    end



  end
end
