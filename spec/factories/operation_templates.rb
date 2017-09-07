# frozen_string_literal: true

FactoryGirl.define do
  factory :operation_template, class: 'RailsWorkflow::OperationTemplate' do
    title 'Operation Template'
    kind 'default'
    is_background true
    association :process_template, factory: :process_template

    factory :parent_operation_template do
      child_process { create :process_template }
    end
  end
end
