FactoryGirl.define do
  factory :operation, :class => 'Workflow::Operation' do
    title "Test Operation"
    status Workflow::Operation::NOT_STARTED

    factory :operation_with_context do
      context { create :context, data: { msg: "Test" }}
    end
  end

  factory :custom_operation, class: 'Workflow::CustomOperation'
end
