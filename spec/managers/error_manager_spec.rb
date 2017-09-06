# frozen_string_literal: true

module RailsWorkflow
  RSpec.describe ErrorManager do
    let(:process_template) { create :process_template }
    let(:process) { create(:process, template: process_template) }
    let(:operation) { create :operation, process: process }
    let(:test_message) { 'Test message' }

    let(:error) { operation.workflow_errors.first }
    let(:error_parent) { operation }
    let(:error_target) { operation }
    let(:error_args) { nil }
    let(:error_parent_type) { RailsWorkflow::Operation }
    let(:error_method) { nil }

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
      # TODO replace with RailsWorkflow::Status::ERROR
      it { expect(error_parent.status).to eq RailsWorkflow::Status::ERROR }

      it { expect(error.message).to eq test_message }

      # TODO check with custom operation / process types
      it { expect(error.parent).to be_a_kind_of(error_parent_type) }

      it { expect(error.data[:target]).to eq error_target }
      it { expect(error.data[:method]).to eq error_method }
      it { expect(error.data[:args]).to eq error_args }
    end

    def raise_error(target, method_name)
      allow(target).to receive(method_name).and_raise(test_message)
    end

    context 'when operation fails to start' do
      let(:error_target) { nil }
      before { raise_error operation, :can_start? }
      let(:failing_method_call) { operation.start }

      it_behaves_like 'workflow failed'
    end

    context 'when operation fails to start waiting' do
      let(:error_target) { nil }
      before { raise_error operation, :update_attribute }
      let(:failing_method_call) { operation.waiting }

      it_behaves_like 'workflow failed'
    end

    # TODO: cover other errors in execute_in_transitions
    context 'when operation execution fails' do
      let(:error_method) { 'execute_in_transaction' }
      before { raise_error operation, :execute }
      let(:failing_method_call) { operation.execute_in_transaction }

      it_behaves_like 'workflow failed'
    end

    context 'when operation completion fails' do
      let(:error_method) { 'complete' }
      let(:error_args) { [RailsWorkflow::Status::DONE] }

      before { raise_error operation, :update_attributes }
      let(:failing_method_call) { operation.complete }

      it_behaves_like 'workflow failed'
    end

    context 'when operation build fails' do
      let(:operation_template) { create :operation_template }
      let(:error) { process.workflow_errors.first }
      let(:error_target) { process_template }
      let(:error_parent) { process }
      let(:error_parent_type) { RailsWorkflow::Process }
      let(:error_method) { 'build_operation' }
      let(:error_args) { [process, operation_template, []] }

      before { raise_error operation_template, :build_operation! }
      let(:failing_method_call) do
        process_template.build_operation(process, operation_template)
      end

      it_behaves_like 'workflow failed'
    end

    context 'when operation build fails' do
      let(:error) { process.workflow_errors.first }
      let(:error_target) { process }
      let(:error_parent) { process }
      let(:error_method) { 'build_dependencies' }
      let(:error_parent_type) { RailsWorkflow::Process }
      let(:error_args) { [operation] }

      before { raise_error process, :matched_templates }
      let(:failing_method_call) { process.build_dependencies(operation) }

      it_behaves_like 'workflow failed'
    end

    context 'when process manager fails to start process' do
      let(:process_manager) { RailsWorkflow::ProcessManager.new(process) }
      let(:error) { process.workflow_errors.first }
      let(:error_target) { nil }
      let(:error_parent) { process }
      let(:error_parent_type) { RailsWorkflow::Process }

      let(:failing_method_call) { process_manager.start_process }
      before { raise_error process, :start }

      it_behaves_like 'workflow failed'
    end
  end
end
