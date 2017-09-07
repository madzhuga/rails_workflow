# frozen_string_literal: true

FactoryGirl.define do
  factory :process, class: 'RailsWorkflow::Process' do
    status RailsWorkflow::Status::NOT_STARTED
    context { create :context, data: { msg: 'Test message' } }
  end
end
