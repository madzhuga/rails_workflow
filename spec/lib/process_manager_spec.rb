# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/contexts/process_template'

module RailsWorkflow
  RSpec.describe ProcessManager do
    include_context 'process template'

    let(:template) { prepare_template }

    let(:process) { described_class.create_process template.id, msg: 'Test' }
    let(:operation_runner) { RailsWorkflow::OperationRunner }

    context 'build process' do
      it 'should create new process' do
        expect(process).to be
        expect(process).to be_kind_of(Process)
        expect(process.status).to eq RailsWorkflow::Status::NOT_STARTED
      end

      it 'with reference to template' do
        expect(process.template).to eq template
      end

      it 'should create new process operations' do
        expect(process.operations.size).to eq 1
        expect(process.operations.first.status)
          .to eq RailsWorkflow::Status::NOT_STARTED
      end

      it 'should create process context' do
        expect(process.context).to be
        expect(process.context.data[:msg]).to eq 'Test'
      end

      it 'should create context for new operation' do
        context = process.operations.first.context
        expect(context).to be
        expect(context.data[:msg]).to eq 'Test'
      end
    end

    context 'start process' do
      context 'start process (in progres)' do
        before :each do
          allow_any_instance_of(RailsWorkflow::ProcessManager)
            .to receive(:complete_process)
          allow_any_instance_of(RailsWorkflow::OperationRunner)
            .to receive(:complete)

          process_manager = RailsWorkflow::ProcessManager.new process
          process_manager.start_process
        end

        it 'should start new process' do
          expect(process.status).to eq RailsWorkflow::Status::IN_PROGRESS
        end

        it 'should start first operations' do
          expect(process.operations.first.status)
            .to eq RailsWorkflow::Status::IN_PROGRESS
        end
      end
    end

    context 'complete operations' do
      let(:manager) { RailsWorkflow::ProcessManager.new process }

      context 'dependent operation' do
        it 'should be created when dependencies is sutisfied' do
          allow_any_instance_of(RailsWorkflow::OperationTemplate)
            .to receive(:resolve_dependency).and_return(false)
          manager.start_process
          operation_runner.new(process.operations.first).complete
          expect(process.operations.size).to eq 1
        end

        it 'should not be created when dependencies is not sutisfied' do
          manager.start_process
          operation_runner.new(process.operations.first).complete
          expect(process.operations.size).to eq 2
        end
      end

      context 'after first operation done' do
        before do
          manager.start_process
          operation_runner.new(process.operations.first).complete
        end

        %i[complete skip cancel].each do |method_name|
          new_method = <<-METHOD
            it 'should complete process if last operation #{method_name}' do
              operation_runner.new(process.operations.last).#{method_name}
              expect(process.status).to eq Process::DONE
            end
          METHOD
          class_eval(new_method)
        end
      end
    end
  end
end
