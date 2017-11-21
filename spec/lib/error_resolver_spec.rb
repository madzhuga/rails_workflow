# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/contexts/process_template'

module RailsWorkflow
  RSpec.describe ErrorResolver do
    include_context 'process template'

    let(:template) { prepare_template }
    let(:process_manager) do
      ProcessManager.new(
        template_id: template.id, context: { msg: 'Test' }
      )
    end

    let(:process) { process_manager.create_process }
    let(:process_runner) { RailsWorkflow::ProcessRunner.new(process) }

    context 'operation fails' do
      let(:operation) { process.operations.first }
      let(:error) { operation.workflow_errors.first }
      let(:error_resolver) { described_class.new(error) }

      context 'to start' do
        before do
          with_failing_instance(Operation, :execute) do
            process_runner.start
          end
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
          allow_any_instance_of(Operation)
            .to receive(:can_start?).and_return(false)

          with_failing_instance(Operation, :update_attribute) do
            process_runner.start
          end
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
          with_failing_instance(Operation, :execute) do
            process_runner.start
          end
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
      let(:operation) { process.operations.first }
      let(:error) { process.workflow_errors.first }
      let(:error_resolver) { described_class.new(error) }

      context 'when operation build fails' do
        before do
          with_failing(Operation, :create) do
            process_runner.start
          end
        end

        it 'set proper process status' do
          expect { error_resolver.retry }
            .to change { process.reload.status }
            .from(Status::ERROR).to(Status::DONE)
        end

        it 'set proper operation status' do
          expect { error_resolver.retry }
            .to change { process.reload.operations&.first&.status }
            .to(Status::DONE)
        end
      end
    end

    context 'process runner fails to start' do
      let(:error) { Error.first }
      let(:error_resolver) { described_class.new(error) }

      context 'when operation build fails' do
        before do
          with_failing_instance(ProcessRunner, :start) do
            process_manager.create_process
            process_manager.start_process
          end
        end

        it 'set proper process status' do
          expect { error_resolver.retry }
            .to change { Process.first.status }
            .from(Status::ERROR).to(Status::DONE)
        end

        it 'creates and completes operations' do
          expect { error_resolver.retry }
            .to change { Process.first.operations.count }
            .from(1).to(2)
        end
      end
    end

    context 'dependency resolver' do
      let(:operation) { process.operations.first }
      let(:error) { process.workflow_errors.first }
      let(:error_resolver) { described_class.new(error) }

      context 'when operation build fails' do
        before do
          with_failing_instance(DependencyResolver, :matched_templates) do
            process_runner.start
          end
        end

        it 'set proper process status' do
          expect { error_resolver.retry }
            .to change { Process.first.status }
            .from(Status::ERROR).to(Status::DONE)
        end

        it 'set proper operation status' do
          expect { error_resolver.retry }
            .to change { Process.first.operations.count }
            .from(1).to(2)
        end
      end
    end

    def with_failing_instance(target_class, method)
      allow_any_instance_of(target_class)
        .to receive(method) { raise 'Some error' }

      yield

      allow_any_instance_of(target_class).to receive(method).and_call_original
    end

    def with_failing(target, method)
      allow(target).to receive(method) { raise 'Some error' }
      yield
      allow(target).to receive(method).and_call_original
    end
  end
end
