# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe Error, type: :model do
    describe '#can_restart_process?' do
      let(:process) { RailsWorkflow::Process.create }
      before do
        allow(subject).to receive(:process).and_return(process)
      end

      it { expect(subject.can_restart_process?).to eq true }

      context 'with errors' do
        before do
          allow(process).to receive(
            :unresolved_errors
          ).and_return ['some_error']
        end

        it { expect(subject.can_restart_process?).to eq false }
      end
    end
  end
end
