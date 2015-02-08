require 'rails_helper'

module Workflow
  RSpec.describe ProcessTemplate, :type => :model do
    let(:template) {
      create :process_template, process_class: "Workflow::TestProcess"
    }

    it 'should init new process' do
      new_process = template.build_process!({})
      expect(new_process).to be_instance_of TestProcess
      expect(new_process.template).to eq template
    end

  end

  class TestProcess < Workflow::Process
  end

end
