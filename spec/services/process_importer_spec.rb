# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe ProcessImporter do
    context 'simple process template' do
      let(:json) do
        JSON.parse(
          File.read(
            Rails.root.join('../support/jsons/process_template.json')
          )
        )
      end
      let(:processor) { ProcessImporter.new(json) }
      let(:process_template) { ProcessTemplate.find_by_uuid(json['process_template']['uuid']) }

      before(:each) do
        processor.process
      end

      it 'should create process template' do
        expect(process_template).to_not be_nil
        expect(process_template.title).to eq 'Test Process'
      end

      it 'should update process template' do
        process_template.update_attribute(:title, 'Some new name')

        # run processor second time to re-import process template and operations
        processor.process

        template = ProcessTemplate.find_by_uuid(process_template.uuid)
        expect(template.title).to eq 'Test Process'
      end

      it 'should create operation templates' do
        expect(process_template.operations.count).to eq 3
      end

      it 'should update operation templates' do
        operation = process_template.operations.first
        operation.update_attribute(:title, 'Some new operation name')

        # run processor second time to re-import process template and operations
        processor.process

        check = OperationTemplate.find(operation.id)
        expect(check.title).to eq 'Default Operation 2'
      end

      it 'should remove absent operation templates' do
        process_template.operations.create(title: 'Some new operation')
        expect(process_template.operations.count).to eq 4

        processor.process
        template = ProcessTemplate.find_by_uuid(process_template.uuid)
        expect(template.operations.count).to eq 3
      end
    end

    context 'dependencies' do
      let(:json) do
        JSON.parse(
          File.read(
            Rails.root.join('../support/jsons/process_template.json')
          )
        )
      end
      let(:processor) { ProcessImporter.new(json) }
      let(:process_template) { ProcessTemplate.find_by_uuid(json['process_template']['uuid']) }

      before(:each) do
        processor.process
      end

      it 'should set dependencies' do
        operation_template = RailsWorkflow::OperationTemplate.find_by_uuid '893ecf5d-b6e5-e0bf-7d07-adcadaafcb75'
        dependency = RailsWorkflow::OperationTemplate.find(operation_template.dependencies.first['id'])
        expect(dependency.uuid).to eq '0347a15a-9298-c4a2-3b5e-b521b614e9e3'
      end
    end

    context 'parent process template' do
      let(:json) do
        JSON.parse(
          File.read(
            Rails.root.join('../support/jsons/parent_process_template.json')
          )
        )
      end
      let(:processor) { ProcessImporter.new(json) }
      let(:process_template) { ProcessTemplate.find_by_uuid(json['process_template']['uuid']) }

      before(:each) do
        processor.process
      end

      it 'should create child process template' do
        child_process_template = ProcessTemplate.find_by_title('Test Child Process')
        expect(child_process_template).to_not be_nil
      end

      it 'should link parent opeartion to child process template' do
        parent_process_template = ProcessTemplate.find_by_title('Test Parent Process')
        child_process_template = ProcessTemplate.find_by_title('Test Child Process')
        parent_operation = parent_process_template.operations
                                                  .select { |o| o.child_process.present? }.first

        expect(parent_operation.child_process).to eq child_process_template
      end
    end

    context 'broken parent process template' do
      let(:json) do
        JSON.parse(
          File.read(
            Rails.root.join('../support/jsons/broken_parent_process_template.json')
          )
        )
      end
      let(:processor) { ProcessImporter.new(json) }
      let(:process_template) { ProcessTemplate.find_by_uuid(json['process_template']['uuid']) }

      it 'should link parent opeartion to child process template' do
        expect { processor.process }.to raise_error(ActiveRecord::RecordNotFound, 'Operation Start Child Process child process template not found by UUID')
      end
    end
  end
end
