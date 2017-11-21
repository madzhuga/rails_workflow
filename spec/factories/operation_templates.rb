# frozen_string_literal: true

FactoryGirl.define do
  factory :operation_template, class: 'RailsWorkflow::OperationTemplate' do
    title 'Operation Template'
    kind 'default'
    type nil
    async nil
    is_background true
    association :process_template, factory: :process_template

    factory :parent_operation_template do
      child_process { create :process_template }
    end

    factory :user_operation_template do
      title 'User Operation'
      kind 'user'
    end

    factory :event do
      title 'Event'
      kind 'event'
      tag 'event'
    end
  end
end
