# frozen_string_literal: true

require 'rails_helper'
require_relative '../../concerns/status_spec.rb'

module RailsWorkflow
  RSpec.describe RailsWorkflow::Process, type: :model do
    it_behaves_like 'Status'
  end
end
