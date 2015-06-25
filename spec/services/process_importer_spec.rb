require 'rails_helper'

module RailsWorkflow
  RSpec.describe ProcessImporter do
    let(:json) do
      JSON.parse(
          File.read(
              Rails.root.join("../support/jsons/process_template.json")
          )
      )
    end
    let(:processor){ ProcessImporter.new(json)}
    let(:process_template){ ProcessTemplate.find_by_uuid(json['process_template']['uuid']) }

    before(:each) do
      processor.process
    end

    it 'should create process template' do
      expect(process_template).to_not be_nil
      expect(process_template.title).to eq "Test Process"

    end

    it 'should update process template' do
      process_template.update_attribute(:title, 'Some new name')

      #run processor second time to re-import process template and operations
      processor.process

      template = ProcessTemplate.find_by_uuid(process_template.uuid)
      expect(template.title).to eq "Test Process"
    end

    it 'should create operation templates' do
      expect(process_template.operations.count).to eq 3
    end

    it 'should update operation templates' do
      operation = process_template.operations.first
      operation.update_attribute(:title, 'Some new operation name')

      #run processor second time to re-import process template and operations
      processor.process

      check = OperationTemplate.find(operation.id)
      expect(check.title).to eq "Default Operation 2"
    end

    it 'should remove absent operation templates' do
      process_template.operations.create(title: 'Some new operation')
      expect(process_template.operations.count).to eq 4

      processor.process
      template = ProcessTemplate.find_by_uuid(process_template.uuid)
      expect(template.operations.count).to eq 3

    end
  end
end
