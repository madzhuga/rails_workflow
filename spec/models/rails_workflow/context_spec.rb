# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe Context, type: :model do
    let(:operation) { create :operation }
    let(:process) { create :process }
    let(:manager) { ProcessManager.new(process) }
    let(:template) do
      create :operation_template, async: true, operation_class: 'RailsWorkflow::UserByGroupOperation'
    end

    before :each do
      allow_any_instance_of(RailsWorkflow::Process).to receive(:manager).and_return(manager)
    end

    context 'prepare body before saving' do
      it 'sould process basic hash' do
        context = create :context, data: { int: 1, date: Date.today, ary: [1, 2, 3], msg: 'Some string' }

        expect(context.body).to match('int' => 1,
                                      'date' => Date.today.to_s,
                                      'ary' => [1, 2, 3],
                                      'msg' => 'Some string')
      end

      it 'should process active records' do
        context = create :context, data: { resource: operation, process: process }
        context.save
        expect(context.body).to match('resource' => {
                                        'id' => operation.id, 'class' => operation.class.to_s
                                      },
                                      'process' => {
                                        'id' => process.id, 'class' => process.class.to_s
                                      })
      end

      it 'should process active record arrays' do
        context = create :context, data: { resources: [operation, process] }
        expect(context.body).to match('resources' => [
                                        { 'id' => operation.id, 'class' => operation.class.to_s },
                                        { 'id' => process.id, 'class' => process.class.to_s }
                                      ])
      end
    end

    context 'prepare data' do
      it 'should process basic hash' do
        context = create :context, parent: operation, data: {
          int: 1,
          date: Date.today,
          ary: [1, 2, 3],
          msg: 'Some string'
        }

        check_context = Context.find(context.id)

        expect(check_context.data).to match(int: 1,
                                            date: Date.today.to_s,
                                            ary: [1, 2, 3],
                                            msg: 'Some string')
      end

      it 'should process active records' do
        context = create :context, parent: operation,
                                   data: { resource: operation, process: process }

        check_context = Context.find(context.id)

        expect(check_context.data[:resource]).to eq operation
        expect(check_context.data[:process]).to eq process
      end

      it 'should process active record arrays' do
        context = create :context, data: { resources: [operation, process] }

        check_context = Context.find(context.id)
        expect(check_context.data[:resources])
          .to match_array([operation, process])
      end
    end

    it 'should be build using operation dependencies contexts' do
      operation = create :operation_with_context, status: RailsWorkflow::Status::ERROR

      child_operation = OperationBuilder.new(
        process, template, [operation]
      ).create_operation

      expect(child_operation.context.data).to match(msg: 'Test')
    end
  end
end
