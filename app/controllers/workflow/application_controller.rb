module Workflow
  class ApplicationController < ActionController::Base
    before_filter only: [:index, :show, :edit] do
      Workflow::OperationTemplate.inheritance_column = nil
      Workflow::Operation.inheritance_column = nil
      Workflow::ProcessTemplate.inheritance_column = nil
    end

  end
end
