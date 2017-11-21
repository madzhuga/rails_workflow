# frozen_string_literal: true

require 'rails_helper'
require_relative './../../support/contexts/process_template_with_events'

module RailsWorkflow
  RSpec.describe ProcessRunner do
    include_context 'process template with events'

    it 'sets not started events to waiting status' do
      expect { process_manager.start_process }
        .to change { process.events.first.status }
        .from(Status::NOT_STARTED).to(Status::WAITING)
    end

    context 'for started process' do
      before { process_manager.start_process }

      it 'event operation catches event' do
        expect { EventManager.create_event(:first_event, a: 'b') }
          .to change { process.events.first.status }
          .from(Status::WAITING).to(Status::DONE)
      end

      it 'process waits for last sync event' do
        process.operations.without_events.first.complete

        expect { process.operations.without_events.first.complete }
          .not_to change { process.status }.from(Status::IN_PROGRESS)
      end

      it 'last sync event finishes process' do
        process.operations.without_events.first.complete
        process.operations.without_events.last.complete

        EventManager.create_event(:first_event, a: 'b')

        expect { EventManager.create_event(:second_event, c: 'd') }
          .to change { process.reload.status }
          .from(Status::IN_PROGRESS).to(Status::DONE)
      end

      it 'first sync event finishes process' do
        process.operations.without_events.first.complete
        process.operations.without_events.last.complete

        EventManager.create_event(:second_event, a: 'b')

        # Now first operation is only not yet finished operation
        # and we finish it by sending this event
        expect { EventManager.create_event(:first_event, c: 'd') }
          .to change { process.reload.status }
          .from(Status::IN_PROGRESS).to(Status::DONE)
      end

      context 'with async event' do
        before do
          OperationTemplate.where(tag: :second_event).first.update(async: true)
        end

        it 'process does not wait for async' do
          process.operations.without_events.first.complete
          process.operations.without_events.last.complete

          expect { EventManager.create_event(:first_event, c: 'd') }
            .to change { process.reload.status }
            .from(Status::IN_PROGRESS).to(Status::DONE)
        end
      end
    end
  end
end
