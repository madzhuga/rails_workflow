# frozen_string_literal: true

require 'rails_helper'
require_relative '../../concerns/status_spec.rb'

module RailsWorkflow
  RSpec.describe Operation, type: :model do
    it_behaves_like 'Status'
    let(:operation_runner) { OperationRunner }

    context '#completable?' do
      describe 'no child process' do
        it { expect(subject).to be_completable }
      end

      describe 'completed child process' do
        before do
          subject.child_process = Process.create(status: Status::DONE)
        end

        it { expect(subject).to be_completable }
      end

      describe 'non-completed child process' do
        before do
          subject.child_process = Process.create(status: Status::WAITING)
        end

        it { expect(subject).not_to be_completable }
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
        operation_runner.new(operation).start
        expect(operation.status).to eq Status::WAITING
      end

      it 'should start child process' do
        allow_any_instance_of(RailsWorkflow::Process)
          .to receive(:can_start?).and_return(true)

        allow_any_instance_of(RailsWorkflow::ProcessRunner)
          .to receive(:completable?).and_return(false)

        parent_operation = create :operation

        parent_operation.child_process = process
        parent_operation.save
        operation_runner.new(parent_operation).start

        expect(parent_operation.status).to eq Status::IN_PROGRESS
        parent_operation.child_process.reload

        expect(parent_operation.child_process.status).to eq Status::IN_PROGRESS
      end
    end

    context 'complete operation ' do
      before :each do
        @manager = ProcessManager.new
        @process = RailsWorkflow::Process.new
        @dependency_resolver = DependencyResolver.new(@process)

        allow(@dependency_resolver).to receive(:build_new_operations)
        allow(DependencyResolver).to receive(:new)
          .and_return(@dependency_resolver)

        # TODO: REWORK
        allow_any_instance_of(Operation)
          .to receive(:manager).and_return(@manager)

        allow_any_instance_of(Operation)
          .to receive(:process).and_return(@process)
      end

      it 'should change state to DONE on complete' do
        # expect(@manager).to receive(:operation_completed)
        subject.complete
        expect(subject.status).to eq Status::DONE
      end

      it 'should change state to SKIP on skip' do
        # expect(@manager).to receive(:operation_completed)
        subject.skip
        expect(subject.status).to eq Status::SKIPPED
      end

      it 'should change state to DONE on complete' do
        # expect(@manager).to receive(:operation_completed)
        subject.cancel
        expect(subject.status).to eq Status::CANCELED
      end
    end
  end
end
