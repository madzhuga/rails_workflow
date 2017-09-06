# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe ProcessBuilder do
    let(:template) do
      create :process_template, process_class: 'RailsWorkflow::TestProcess'
    end

    let(:new_process) { described_class.new(template, {}).create_process! }

    it { expect(new_process).to be_instance_of TestProcess }
    it { expect(new_process.template).to eq template }
  end

  class TestProcess < RailsWorkflow::Process
  end
end
