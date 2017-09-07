# frozen_string_literal: true

FactoryGirl.define do
  factory :workflow_error, class: 'RailsWorkflow::Error' do
    message 'MyString'
    stack_trace 'MyText'
    parent_id 1
    parent_type 'MyString'
  end
end
