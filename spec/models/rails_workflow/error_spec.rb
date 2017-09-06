# frozen_string_literal: true

module RailsWorkflow
  RSpec.describe Error, type: :model do
    # TODO: Move all to error manager spec
    # it 'should create error if process failed to start' do
    #   manager = Workflow::ProcessManager.new process
    #   allow(process).to receive(:start).and_raise(test_message)
    #
    #   expect {
    #     manager.start_process
    #   }.to change { Workflow::Error.count }.by(1)
    #
    #   error = Workflow::Error.last
    #   expect(error.message).to eq test_message
    #   expect(error.parent).to eq process
    #   expect(error.parent.status).to eq Workflow::Process::ERROR
    # end
    #
    # it 'should create error if process manager init fails' do
    #   allow_any_instance_of(Workflow::OperationTemplate)
    #     .to receive(:build_operation!).and_raise(test_message)
    #
    #   expect{
    #     ProcessManager.start_process process_template.id, {}
    #   }.to change { Workflow::Error.count }.by(1)
    #
    #   error = Workflow::Error.last
    #   expect(error.message).to eq test_message
    #   expect(error.parent).to be_a_kind_of(Workflow::Process)
    #   expect(error.parent.status).to eq Workflow::Process::ERROR
    # end
    #
    # it 'should create error if process manager build process fails' do
    #   allow_any_instance_of(Workflow::OperationTemplate)
    #     .to receive(:build_operation!).and_raise(test_message)
    #
    #   expect{
    #     ProcessManager.start_process process_template.id, {}
    #   }.to change { Workflow::Error.count }.by(1)
    #
    #   error = Workflow::Error.last
    #   expect(error.message).to eq test_message
    #   expect(error.parent).to be_a_kind_of(Workflow::Process)
    #   expect(error.parent.status).to eq Workflow::Process::ERROR
    # end
    #
    #
    #
    # it 'should create error if operation execute fails' do
    #   allow_any_instance_of(Workflow::Operation)
    #     .to receive(:execute).and_raise(test_message)
    #
    #   expect{
    #     operation.start
    #   }.to change { Workflow::Error.count }.by(1)
    #
    #   error = Workflow::Error.last
    #   expect(error.message).to eq test_message
    #   expect(error.parent).to be_a_kind_of(Workflow::Operation)
    #   expect(error.parent.status).to eq Workflow::Operation::ERROR
    # end
    #
    # it 'should create error if operation complete fails' do
    #   allow_any_instance_of(Workflow::ProcessManager)
    #     .to receive(:operation_complete).and_raise(test_message)
    #
    #   expect{
    #     operation.manager = Workflow::ProcessManager.new process
    #     operation.complete
    #   }.to change { Workflow::Error.count }.by(1)
    #
    #   error = Workflow::Error.last
    #   expect(error.message).to eq test_message
    #   expect(error.parent).to be_a_kind_of(Workflow::Operation)
    #   expect(error.parent.status).to eq Workflow::Operation::ERROR
    # end
    #
    # it 'should create error if operation build failed' do
    #
    #   operation_template = create :operation_template
    #   allow_any_instance_of(Workflow::OperationTemplate)
    #     .to receive(:operation_class).and_return("NotExistingClass")
    #
    #   expect {
    #     operation =
    #       operation_template.build_operation! process
    #   }.to change { Workflow::Error.count }.by(1)
    #
    #   error = Workflow::Error.last
    #   expect(error.message)
    #     .to eq "undefined method `create' for \"NotExistingClass\":String"
    #   expect(error.parent).to be_a_kind_of(Workflow::Process)
    #   expect(error.parent.status).to eq Workflow::Process::ERROR
    #
    # end
    #
    # it 'should set default class to parent operation' do
    #
    #   allow_any_instance_of(Workflow::CustomOperation)
    #     .to receive(:execute).and_raise("Some exception")
    #   operation = create :custom_operation
    #
    #   expect {
    #     operation.start
    #   }.to change { Workflow::Error.count }.by(1)
    #
    #   expect(operation.workflow_errors.first.parent_type)
    #     .to eq "Workflow::Operation"
    # end
    #
  end
end
