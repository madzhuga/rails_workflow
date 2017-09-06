# frozen_string_literal: true

shared_examples_for 'Status' do
  context '.status_code_for' do
    [
      ['in_progress', RailsWorkflow::Status::IN_PROGRESS],
      ['done',        RailsWorkflow::Status::DONE],
      ['not_started', RailsWorkflow::Status::NOT_STARTED],
      ['waiting',     RailsWorkflow::Status::WAITING],
      ['error',       RailsWorkflow::Status::ERROR]
    ].each do |word, code|
      it "return code for #{word}" do
        expect(described_class.status_code_for(word)).to eq code
      end
    end
  end

  # let(:model) { described_class } # the class that includes the concern
  #
  #
  # it "has a full name" do
  #   person = FactoryGirl.create(model.to_s.underscore.to_sym, first_name: "Stewart", last_name: "Home")
  #   expect(person.full_name).to eq("Stewart Home")
  # end
end
