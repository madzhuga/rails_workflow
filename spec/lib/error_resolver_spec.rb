# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/rails_workflow/prepare_template'

module RailsWorkflow
  RSpec.describe ErrorResolver do
    include PrepareTemplate

    let(:template) { prepare_template }
    let(:process) { ProcessManager.create_process template.id, msg: 'Test' }
    let(:process_runner) { RailsWorkflow::ProcessRunner.new(process) }

    context 'when operation fails to start' do
      let(:operation) { process.operations.first }
      let(:error) { operation.workflow_errors.first }
      let(:error_resolver) { described_class.new(error) }

      before do
        allow(operation).to receive(:execute) { raise 'Some error' }

        allow(Operation).to receive(:find).and_call_original
        allow(Operation)
          .to receive(:find).with(operation.id).and_return(operation)

        process_runner.start
        process.reload

        allow(operation).to receive(:execute) { true }
      end

      it 'retries operation error' do
        expect { error_resolver.retry }
          .to change { process.reload.status }
          .from(Status::ERROR).to(Status::DONE)
      end
    end
  end
end
