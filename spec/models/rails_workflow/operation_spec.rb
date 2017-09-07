# frozen_string_literal: true

require 'rails_helper'
require_relative '../../concerns/status_spec.rb'

module RailsWorkflow
  RSpec.describe Operation, type: :model do
    it_behaves_like 'Status'

    # TODO: move to separate spec for OperationBuilder
    context 'Default Builder' do
      let(:template) do
        create :operation_template,
               async: true,
               operation_class: 'RailsWorkflow::UserByGroupOperation'
      end

      let(:manager) { ProcessManager.new(process) }
      let(:process) { create :process }

      let(:operation) do
        OperationBuilder.new(process, template).create_operation
      end

      before :each do
        allow_any_instance_of(RailsWorkflow::Process)
          .to receive(:manager).and_return(manager)
      end

      it 'should fill title and async from template' do
        expect(operation.title).to eq template.title
        expect(operation.async).to eq template.async
        expect(operation.is_background).to eq template.is_background
      end

      context 'should set dependencies' do
        it 'from template' do
          operation = create :operation, status: Status::ERROR

          operation_with_dependencies = OperationBuilder.new(
            process, template, [operation]
          ).create_operation

          dependencies = [
            {
              'operation_id' => operation.id,
              'status' => operation.status
            }
          ]

          expect(operation_with_dependencies.dependencies).to eq dependencies
        end

        it 'when template dependencies is blank' do
          expect(operation.dependencies).to eq []
        end
      end

      it 'should build correct class' do
        expect(operation).to be_kind_of UserByGroupOperation
      end

      it 'should set reference to operation template' do
        expect(operation.template).to eq template
      end

      it 'should set process' do
        expect(operation.process).to eq process
        expect(operation.process_id).to eq process.id
      end

      it 'should set manager' do
        expect(operation.manager).to eq manager
        operation.manager = manager
      end

      it 'should set status NOT STARTED' do
        expect(operation.status).to eq Status::NOT_STARTED
      end

      it 'should build child process' do
        parent_template = create :parent_operation_template

        parent_operation = OperationBuilder.new(
          process, parent_template, [operation]
        ).create_operation

        expect(parent_operation.child_process)
          .to be_a_kind_of RailsWorkflow::Process
      end

      it 'should save operation' do
        expect(operation.persisted?).to be true
      end
    end

    # TODO: move to separate spec for OperationAssignment
    context 'Operation Assignment' do
      let(:operation) { create :operation }
      let(:other_user) { create :user, email: 'other@user.com' }
      let(:user) { create :user }

      it 'should assigns operation to user' do
        operation.assign user
        expect(operation.assignment).to eq user
      end

      it 'should set is_active to active operation only for other operation' do
        operation.assign user

        other_operation = create :operation
        other_operation.assign user

        expect(other_operation.is_active).to eq true

        operation.reload
        expect(operation.is_active).to eq false
      end

      it 'should restore operation initial assignment' do
        operation.assign user
        operation.cancel_assignment user
        expect(operation.assignment).to be_nil
        expect(operation.is_active).to be false
      end

      it 'should not allow to assign already assigned operation' do
        operation.assign user

        expect(operation.can_be_assigned?(other_user)).to be false

        operation.assign other_user
        expect(operation.assignment).to eq user

        operation.reload
        expect(operation.assignment).to eq user
      end

      it 'should not allow to cancel other user assignment' do
        operation.assign user
        operation.cancel_assignment other_user
        expect(operation.assignment).to eq user
      end

      it 'should return true if user assigned' do
        operation.assign user
        expect(operation.assigned?(user)).to be true
        expect(operation.assigned?(other_user)).to be false
      end

      it 'should return collection by scope' do
        role_template = create :operation_template, role: :admin
        group_template = create :operation_template, group: 'some_group'

        group_operation = create :operation,
                                 status: Status::WAITING,
                                 template: group_template

        role_operation = create :operation,
                                status: Status::WAITING,
                                template: role_template

        user = create :user, role: :admin

        role_operations = Operation.available_for_user(user)
        expect(role_operations).to match_array([role_operation])

        fake_user = create :user, email: 'fake@email.com', role: 'fake'
        expect(Operation.available_for_user(fake_user)).to eq []

        role_operation.assign user
        expect(Operation.unassigned)
          .to match_array [group_operation]
      end
    end

    # TODO: move to separate spec for Operation Runner
    context 'Operation Runner' do
      let(:operation) { create :operation_with_context }
      let(:process) { create :process }

      it 'should be set to WAITING if can not start' do
        allow(operation).to receive(:can_start?).and_return(false)
        operation.start
        expect(operation.status).to eq Status::WAITING
      end

      it 'should start child process' do
        allow_any_instance_of(RailsWorkflow::Process)
          .to receive(:can_start?).and_return(true)

        allow_any_instance_of(RailsWorkflow::ProcessRunner)
          .to receive(:can_complete?).and_return(false)

        parent_operation = create :operation

        parent_operation.child_process = process
        parent_operation.save
        parent_operation.start

        expect(parent_operation.status).to eq Status::IN_PROGRESS
        parent_operation.child_process.reload

        expect(parent_operation.child_process.status).to eq Status::IN_PROGRESS
      end

      it 'should not complete if child process is in progress'
    end

    context 'complete operation ' do
      before :each do
        @manager = ProcessManager.new
        allow_any_instance_of(Operation)
          .to receive(:manager).and_return(@manager)
      end

      it 'should change state to DONE on complete' do
        expect(@manager).to receive(:operation_completed)
        subject.complete
        expect(subject.status).to eq Status::DONE
      end

      it 'should change state to SKIP on skip' do
        expect(@manager).to receive(:operation_completed)
        subject.skip
        expect(subject.status).to eq Status::SKIPPED
      end

      it 'should change state to DONE on complete' do
        expect(@manager).to receive(:operation_completed)
        subject.cancel
        expect(subject.status).to eq Status::CANCELED
      end
    end
  end
end
