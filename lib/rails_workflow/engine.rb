module RailsWorkflow
  class Engine < ::Rails::Engine
    isolate_namespace RailsWorkflow

    config.generators do |g|
      g.template_engine :slim
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end


  end
end
