# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'rails_workflow/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'rails_workflow'
  s.version     = RailsWorkflow::VERSION
  s.authors     = ['Maxim Madzhuga']
  s.email       = ['maximmadzhuga@gmail.com']
  s.homepage    = 'https://github.com/madzhuga/rails_workflow'
  s.summary     = 'OSS Workflow engine implementation'
  s.description = <<-DESC
    Rails engine allowing to configure and manage business processes in rails
    including user operations, background operations, etc. '
  DESC
  s.license = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_runtime_dependency 'rails', '>= 4.1.0'
  s.add_runtime_dependency 'bootstrap-rails-engine'
  s.add_runtime_dependency 'slim-rails'
  s.add_runtime_dependency 'will_paginate'
  s.add_runtime_dependency 'draper'
  s.add_runtime_dependency 'sidekiq'
  s.add_runtime_dependency 'guid'
  s.add_runtime_dependency 'active_model_serializers'
  s.add_runtime_dependency 'jquery-rails'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'capybara'

  s.test_files = Dir['spec/**/*']
end
