# Rails Workflow Engine

[![Build Status](https://semaphoreci.com/api/v1/madzhuga/rails_workflow/branches/master/shields_badge.svg)](https://semaphoreci.com/madzhuga/rails_workflow)  [![Code Climate](https://codeclimate.com/github/madzhuga/rails_workflow/badges/gpa.svg)](https://codeclimate.com/github/madzhuga/rails_workflow)    [![Join the chat at https://gitter.im/madzhuga/rails_workflow](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/madzhuga/rails_workflow?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)  
## Overview

Rails Workflow allows you to organize your application business logic by joining user- and auto- operations in processes. You can
configure, create and manage processes to easily build project management systems, sales / product provisioning systems,
ERP, CMS, etc.

Rails Workflow is mountable Rails engine and can be mounted to any Rails application.

All processes, configurations, operations and their data is persisted for processing and supporting purposes.
Engine has UI to configure process templates and manage existing processes.

![Rails Workflow Engine](http://madzhuga.github.io/rails_workflow/images/rails_workflow_screenshot.png)
### Main features:
* It is mountable rails engine.
* Allows to configure process and operation templates.
* Allows to configure syncronous and asyncronous operations.
* Allows to run operations in background
* Provides operations exceptions/errors monitoring and management.
* Allows to build hierarchical synchronous and asynchronous processes.
* Allows to split process implementation to operations isolating logic.
* Allows to reuse operations in different processes.
* Every operation runs in it's own transaction and has separate context.
* Process may be canceled, manually changed, rolled back, reset to any specific operation.
* Allow to track operations flow and their context, errors, user activities etc.

### User Interface
* It has UI for processes configuration and management.
* UI is bootstrapped and can be easily changed to fit main rails application design.

### Documentation
You can find tutorials and documentation [here](https://github.com/madzhuga/rails_workflow/wiki)

## Installation

Add to your application's Gemfile:

```ruby
gem 'rails_workflow'
```

And then execute:

```sh
$ bundle install
```

and mount it to /workflow routes:
```ruby
Rails.application.routes.draw do
  ...
  mount RailsWorkflow::Engine => '/workflow', as: 'workflow'
  ...
end
```
Generate all models:
```sh
$ rails generate rails_workflow:install
$ bundle exec rake db:migrate
```

I am developing this engine using PostgreSQL database. In case if you using MySQL, add following
to your config/initializers/workflow.rb file:
```ruby
RailsWorkflow.setup do |config|
  config.sql_dialect= 'mysql'
end
```

### Help and support
Feel free to contact me if you have some questions or need some help.
