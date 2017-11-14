# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe OperationBuilder do
    let(:operation_runner) { OperationRunner }
    let(:manager) { ProcessManager.new(process) }
    let(:process) { create :process }
    let(:operation) { described_class.new(process, template).create_operation }

    let(:template) do
      create :operation_template,
             operation_class: 'RailsWorkflow::UserByGroupOperation'
    end

    before do
      allow_any_instance_of(RailsWorkflow::Process)
        .to receive(:manager).and_return(manager)
    end

    it { expect(operation.title).to eq template.title }
    it { expect(operation.async).to eq template.async }
    it { expect(operation.is_background).to eq template.is_background }
    it { expect(operation).to be_kind_of UserByGroupOperation }
    it { expect(operation.template).to eq template }
    it { expect(operation.process).to eq process }
    it { expect(operation.manager).to eq manager }
    it { expect(operation.status).to eq Status::NOT_STARTED }
    it { expect(operation.persisted?).to be true }

    context 'sets dependencies' do
      context 'from template' do
        let(:operation) { create :operation, status: Status::ERROR }
        let(:dependencies) do
          [
            { 'operation_id' => operation.id, 'status' => operation.status }
          ]
        end
        let(:operation_with_dependencies) do
          described_class.new(process, template, [operation]).create_operation
        end

        it do
          expect(operation_with_dependencies.dependencies).to eq dependencies
        end
      end

      it 'when no dependencies' do
        expect(operation.dependencies).to eq []
      end
    end

    context 'operation context data' do
      it { expect(operation.data).to eq(msg: 'Test message') } # from factory

      context 'custom' do
        before do
          new_class = Class.new(RailsWorkflow::OperationTemplate) do
            def after_operation_create(new_operation)
              new_operation.data[:new_key] = 'abc'
            end
          end
          stub_const('NewTemplateClass', new_class)
        end

        let(:operation_template) do
          create :operation_template,
                 type: 'NewTemplateClass',
                 operation_class: 'RailsWorkflow::UserByGroupOperation'
        end

        let(:template) { operation_template.becomes(NewTemplateClass) }

        it { expect(operation.data).to include(new_key: 'abc') }
      end
    end

    context 'should build child process' do
      let(:parent_template) { create :parent_operation_template }

      let(:parent_operation) do
        described_class.new(
          process, parent_template, [operation]
        ).create_operation
      end

      it do
        expect(parent_operation.child_process)
          .to be_a_kind_of RailsWorkflow::Process
      end
    end
  end
end
