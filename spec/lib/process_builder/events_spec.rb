# frozen_string_literal: true

require 'rails_helper'
require_relative './../../support/contexts/process_template_with_events'

module RailsWorkflow
  RSpec.describe ProcessBuilder do
    include_context 'process template with events'

    context 'independent event' do
      it 'creates two operations' do
        # first independent operation and first event
        expect(process.operations.size).to eq 2
      end

      it 'creates event' do
        expect(process.events.size).to eq 1
      end

      it do
        expect(process.events.first.status)
          .to eq RailsWorkflow::Status::NOT_STARTED
      end

      it 'creates event context' do
        event = process.events.first
        expect(event.data).to include(some: 'value')
      end
    end
  end
end
