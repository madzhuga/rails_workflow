# frozen_string_literal: true

FactoryGirl.define do
  factory :operation, class: 'RailsWorkflow::Operation' do
    title 'Test Operation'
    status RailsWorkflow::Status::NOT_STARTED

    factory :operation_with_context do
      context { create :context, data: { msg: 'Test' } }
    end
  end

  factory :custom_operation, class: 'RailsWorkflow::CustomOperation'
end
