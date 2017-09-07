# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'

# require File.expand_path("../../config/environment", __FILE__)
require File.expand_path('../dummy/config/environment', __FILE__)
require 'rspec/rails'
require 'factory_girl'
require 'support/controller_macros'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

require_relative '../spec/factories/process_templates.rb'
require_relative '../spec/factories/operation_templates.rb'
require_relative '../spec/factories/operations.rb'
require_relative '../spec/factories/processes.rb'
require_relative '../spec/factories/user.rb'
require_relative '../spec/factories/context.rb'
require_relative '../spec/support/rails_workflow/custom_operation_template.rb'
require_relative '../spec/support/rails_workflow/custom_operation.rb'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.extend ControllerMacros, type: :controller
end
