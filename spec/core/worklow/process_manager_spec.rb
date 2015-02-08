require 'rails_helper'

module Workflow
  RSpec.describe ProcessManager, :type => :model do

    let(:template) {
      template = create :process_template
      operation = create :operation_template, process_template: template

      dependencies = [
          {
              "id" => operation.id,
              "statuses" => [Workflow::OperationStatus::DONE]
          }
      ]

      create :operation_template, process_template: template, dependencies: dependencies

      template
    }

    let(:process) do
      ProcessManager.build_process template.id, { msg: "Test" }
    end

    context 'build process' do

      it 'should create new process' do
        expect(process).to_not be_nil
        expect(process).to be_kind_of(Process)
        expect(process.status).to eq Workflow::Process::NOT_STARTED
      end

      it 'with reference to template' do
        expect(process.template).to eq template
      end

      it 'should create new process operations' do
        expect(process.operations.size).to eq 1
        expect(process.operations.first.status).to eq Workflow::Operation::NOT_STARTED
      end

      it 'should create process context' do
        expect(process.context).to_not be_nil
        expect(process.context.data[:msg]).to eq "Test"
      end
      it 'should create context for new operation' do
        context = process.operations.first.context
        expect(context).to_not be_nil
        expect(context.data[:msg]).to eq "Test"
      end
    end

    context 'start process' do
      context 'start process (in progres)' do
        before :each do
          allow_any_instance_of(Workflow::ProcessManager).to receive(:complete_process)
          allow_any_instance_of(Workflow::Operation).to receive(:complete)
          process_manager = Workflow::ProcessManager.new process
          process_manager.start_process
        end

        it 'should start new process' do
          expect(process.status).to eq Workflow::Process::IN_PROGRESS
        end

        it 'should start first operations' do
          expect(process.operations.first.status).to eq Workflow::Operation::IN_PROGRESS
        end
      end
    end

    context 'complete operations' do
      let(:manager) {
        Workflow::ProcessManager.new process
      }

      context 'dependent operation' do
        it 'should be created when dependencies is sutisfied' do
          allow_any_instance_of(Workflow::OperationTemplate).to receive(:resolve_dependency).and_return(false)
          manager.start_process
          process.operations.first.complete
          expect(process.operations.size).to eq 1
        end
        it 'should not be created when dependencies is not sutisfied' do
          manager.start_process
          process.operations.first.complete
          expect(process.operations.size).to eq 2
        end
      end

      it 'should complete process if last operation complete' do
        manager.start_process
        process.operations.first.complete
        process.operations.last.complete
        process.reload
        expect(process.status).to eq Process::DONE
      end
    end
  end
end
