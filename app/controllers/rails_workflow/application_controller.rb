module RailsWorkflow
  class ApplicationController < ::ApplicationController
    before_filter only: [:index, :show, :edit] do
      RailsWorkflow::OperationTemplate.inheritance_column = nil
      RailsWorkflow::Operation.inheritance_column = nil
      RailsWorkflow::ProcessTemplate.inheritance_column = nil
    end

    # before_action :authenticate_user!
  end
end
