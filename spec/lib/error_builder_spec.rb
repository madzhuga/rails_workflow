# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe ErrorBuilder do
    # TODO: add process builder failures tests
    let(:process_template) { create :process_template }
    let(:process) { create(:process, template: process_template) }
    let(:operation) { create :operation, process: process }
    let(:operation_runner) { OperationRunner.new(operation) }
    let(:test_message) { 'Test message' }

    let(:error) { operation.workflow_errors.first }
    let(:error_parent) { operation }
    let(:error_target) { operation }
    let(:error_args) { nil }
    let(:error_parent_type) { RailsWorkflow::Operation }
    let(:error_method) { 'start_process' }

    shared_context 'workflow failed' do
      specify do
        expect { failing_method_call }
          .to change { RailsWorkflow::Error.count }.by(1)
      end

      context 'manager creates error' do
        before { failing_method_call }
        it_behaves_like 'has workflow error'
      end
    end

    shared_examples 'has workflow error' do
      it { expect(process.reload.status).to eq RailsWorkflow::Status::ERROR }

      it { expect(error_parent.workflow_errors.count).to eq 1 }
      it { expect(error_parent.status).to eq RailsWorkflow::Status::ERROR }

      it { expect(error.message).to eq test_message }

      # TODO: check with custom operation / process types
      it { expect(error.parent).to be_a_kind_of(error_parent_type) }

      it { expect(error.data[:target]).to eq error_target }
      it { expect(error.data[:method]).to eq error_method }
      it { expect(error.data[:args]).to eq error_args }
    end

    def raise_error(target, method_name)
      allow(target).to receive(method_name).and_raise(test_message)
    end

    context 'when operation fails to start' do
      let(:error_target) { 'operation_runner' }
      before { raise_error operation, :can_start? }
      let(:failing_method_call) { operation.start }
      let(:error_method) { 'start' }

      it_behaves_like 'workflow failed'
    end

    context 'when operation fails to start waiting' do
      let(:error_target) { 'operation_runner' }
      before { raise_error operation, :update_attribute }
      let(:failing_method_call) { operation_runner.waiting }
      let(:error_method) { 'waiting' }

      it_behaves_like 'workflow failed'
    end

    # TODO: cover other errors in execute_in_transitions
    context 'when operation execution fails' do
      let(:error_method) { 'execute_in_transaction' }
      let(:error_target) { 'operation_runner' }
      before { raise_error(operation, :execute) }
      let(:failing_method_call) { operation_runner.execute_in_transaction }

      it_behaves_like 'workflow failed'
    end

    context 'when operation build fails' do
      let(:operation_template) { create :operation_template }
      let(:error) { process.workflow_errors.first }
      let(:error_target) { 'operation_builder' }
      let(:error_parent) { process }
      let(:error_parent_type) { RailsWorkflow::Process }
      let(:error_method) { 'create_operation' }
      let(:error_args) { [process, operation_template, []] }
      let(:operation_builder) do
        OperationBuilder.new(process, operation_template)
      end

      before { raise_error operation_builder, :create_operation! }
      let(:failing_method_call) do
        operation_builder.create_operation
      end

      it_behaves_like 'workflow failed'
    end

    context 'when new operations build fails' do
      let(:error) { process.workflow_errors.first }
      let(:error_target) { 'dependency_resolver' }
      let(:error_parent) { process }
      let(:error_method) { 'build_new_operations' }
      let(:error_parent_type) { RailsWorkflow::Process }
      let(:error_args) { [operation] }
      let(:dependency_resolver) { DependencyResolver.new(process) }

      before { raise_error dependency_resolver, :matched_templates }
      let(:failing_method_call) do
        dependency_resolver.build_new_operations(operation)
      end

      it_behaves_like 'workflow failed'
    end

    context 'when process manager fails to start process' do
      let(:process_manager) { RailsWorkflow::ProcessManager.new(process) }
      let(:process_runner) { RailsWorkflow::ProcessRunner.new(process) }
      let(:error) { process.workflow_errors.first }
      let(:error_target) { 'process_manager' }
      let(:error_parent) { process }
      let(:error_parent_type) { RailsWorkflow::Process }

      let(:failing_method_call) { process_manager.start_process }
      before do
        allow(RailsWorkflow::ProcessRunner).to receive(:new)
          .and_return(process_runner)

        raise_error process_runner, :start
      end

      it_behaves_like 'workflow failed'
    end
  end
end
