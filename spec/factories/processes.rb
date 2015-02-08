FactoryGirl.define do
  factory :process, :class => 'Workflow::Process' do
    status Workflow::Process::NOT_STARTED
    context { create :context, data: {msg: "Test message"} }
  end

end
