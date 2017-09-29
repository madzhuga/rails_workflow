# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/rails_workflow/prepare_template'

module RailsWorkflow
  RSpec.describe ErrorResolver do
    include PrepareTemplate

    let(:template) { prepare_template }
    let(:process) { ProcessManager.create_process template.id, msg: 'Test' }
    let(:process_runner) { RailsWorkflow::ProcessRunner.new(process) }

    context 'operation fails' do
      let(:operation) { process.operations.first }
      let(:error) { operation.workflow_errors.first }
      let(:error_resolver) { described_class.new(error) }

      before do
        allow(Operation).to receive(:find).and_call_original
        allow(Operation).to receive(:find)
          .with(operation.id).and_return(operation)
      end

      context 'to start' do
        before do
          allow(operation).to receive(:execute) { raise 'Some error' }
          process_runner.start
          process.reload

          allow(operation).to receive(:execute) { true }
        end

        it 'set proper process status after retry' do
          expect { error_resolver.retry }
            .to change { process.reload.status }
            .from(Status::ERROR).to(Status::DONE)
        end

        it 'set proper operation status after retry' do
          expect { error_resolver.retry }
            .to change { process.reload.operations.first.status }
            .from(Status::ERROR).to(Status::DONE)
        end
      end

      context 'to wait' do
        before do
          allow(operation).to receive(:update_attribute) { raise 'Some error' }
          allow(operation).to receive(:can_start?).and_return(false)
          allow(Operation).to receive(:new).and_return(operation)

          process_runner.start
          process.reload

          allow(operation).to receive(:update_attribute).and_return(true)
        end

        it 'set proper process status' do
          expect { error_resolver.retry }
            .to change { process.reload.status }
            .from(Status::ERROR).to(Status::IN_PROGRESS)
        end

        it 'set proper operation status' do
          expect { error_resolver.retry }
            .to change { process.reload.operations.first.status }
            .from(Status::ERROR).to(Status::WAITING)
        end
      end

      context 'execution fails' do
        before do
          allow(operation).to receive(:execute) { raise 'Some error' }
          allow(Operation).to receive(:new).and_return(operation)

          process_runner.start
          process.reload

          allow(Operation).to receive(:new).and_call_original
          allow(operation).to receive(:execute).and_return(true)
        end

        it 'set proper process status' do
          expect { error_resolver.retry }
            .to change { process.reload.status }
            .from(Status::ERROR).to(Status::DONE)
        end

        it 'set proper operation status' do
          expect { error_resolver.retry }
            .to change { process.reload.operations.first.status }
            .from(Status::ERROR).to(Status::DONE)
        end
      end
    end

    context 'operation building fails' do
      context 'when operation build fails' do
        pending
      end

      context 'when new operations build fails' do
        pending
      end
    end

    context 'when process manager fails to start process' do
      pending
    end
  end
end
