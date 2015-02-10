FactoryGirl.define do
  factory :process, :class => "RailsWorkflow::Process" do
    status RailsWorkflow::Process::NOT_STARTED
    context { create :context, data: {msg: "Test message"} }
  end

end
