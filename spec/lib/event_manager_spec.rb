# frozen_string_literal: true

require 'rails_helper'
require_relative './../support/contexts/process_template_with_events'

module RailsWorkflow
  RSpec.describe EventManager do
    include_context 'process template with events'

    it 'ignores not waiting events' do
      expect { described_class.create_event(:first_event, a: 'b') }
        .not_to change { process.events.first.status }
        .from(Status::NOT_STARTED)
    end

    context 'when process started' do
      before { process_manager.start_process }

      it 'merges event context to event operation context' do
        described_class.create_event(:first_event, a: 'b')
        expect(process.events.first.data).to include(a: 'b')
      end

      it 'merges event context to next operations' do
        described_class.create_event(:first_event, a: 'b')
        new_operations = dependent_operations(process, process.events.first)

        new_operations.each do |new_operation|
          expect(new_operation.data).to include(a: 'b')
        end
      end
    end

    context 'multiple event operation' do
      # TODO: if first event operation failed to complete - should
      # not affect other event operations for same event
      before do
        first_event_template.first.update(source: { multiple: true })
        process_manager.start_process
      end

      let(:first_event_template) do
        template.operations.where(tag: :first_event)
      end
      let(:first_event_operations) { process.events.where(tag: :first_event) }

      it 'creates new event operation' do
        expect { described_class.create_event(:first_event, a: 'b') }
          .to change { first_event_operations.count }.from(1).to(2)
      end

      it 'new event operation has waiting status' do
        expect { described_class.create_event(:first_event, a: 'b') }
          .not_to change {
            first_event_operations.where(status: Status::WAITING).count
          }
      end

      it 'should not affect next event operations context'
    end

    describe 'event matching' do
      context 'matches event to event operation' do
        let(:custom_event_operation) do
          Class.new(EventOperation) do
            def match(event_context)
              event_context[:check] == true
            end
          end
        end
        let(:first_event) { process.events.where(tag: :first_event).first }
        let(:first_event_template) do
          OperationTemplate.where(tag: :first_event).first
        end

        before do
          stub_const('CustomEventOperation', custom_event_operation)

          first_event_template.update(operation_class: 'CustomEventOperation')
          process_manager.start_process
        end

        it 'ignores not matching event' do
          expect { described_class.create_event(:first_event, check: false) }
            .not_to change { first_event.reload.status }
            .from(Status::WAITING)

          expect { described_class.create_event(:first_event, {}) }
            .not_to change { first_event.reload.status }
            .from(Status::WAITING)
        end

        it 'catches matching event' do
          described_class.create_event(:first_event, check: true)

          expect { described_class.create_event(:first_event, check: true) }
            .not_to change { first_event.reload.status }
            .from(Status::DONE)
        end
      end
    end

    def dependent_operations(process, completed_operation)
      process.operations.reload.select do |operation|
        operation.dependencies.any? do |dependency|
          dependency['operation_id'] == completed_operation.id
        end
      end
    end
  end
end
