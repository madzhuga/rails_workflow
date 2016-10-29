FactoryGirl.define do
  factory :operation, class: 'RailsWorkflow::Operation' do
    title 'Test Operation'
    status RailsWorkflow::Operation::NOT_STARTED

    factory :operation_with_context do
      context { create :context, data: { msg: 'Test' } }
    end
  end

  factory :custom_operation, class: 'RailsWorkflow::CustomOperation'
end
