# frozen_string_literal: true

require 'rails_workflow/engine'
require 'rails_workflow/config'

module RailsWorkflow
  def self.config
    Config.instance
  end

  def self.setup
    yield config
  end
end
