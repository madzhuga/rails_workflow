#Rails Workflow Engine

## Overview

Rails Workflow allows you to organize your business by joining user and auto- operations in processes. You can
configure, create and manage processes to easily build project management systems, sales / product provisioning systems,
ERP, CMS, etc.

Rails Workflow is mountable Rails engine and can be mounted to any Rails application.

All processes, configurations, operations and their data is persisted for processing and supporting purposes.
Engine has UI to configure process templates and manage existing processes.

![Rails Workflow Engine](https://dl.dropboxusercontent.com/u/192451/rails_workflow_screenshot.png)
### Main features:
* It is mountable rails engine.
* Allows to configure process and operation templates.
* Allows to configure syncronous and asyncronous operations.
* Allows to run operations in background
* Provides operations exceptions/errors monitoring and management.
* Allows to build hierarchical syncronous and asyncronous processes.
* Allows to split process implementation to operations isolating logic.
* Allows to reuse operations in different processes.
* Every operation runs in it's own transaction and has separate context.
* Process may be canceled, manually changed, rolled back, reset to any specific operation.
* Allow to track operations flow and their context, errors, user activities etc.

### User Interface
* It has UI for processes configuration and management.
* UI is bootstrapped and can be easily changed to fit main rails application design.

## Tutorial
Working on it right now and going to post it shortly (today or tomorrow).

## Process
Process is a set of operations. Operations has 3 kinds - automatic operations, user operations and child process operations. They all will be described bellow in details. Process has template whith operation templates so that user can specify operations for process and specify their dependencies. When operation is completed or changing it's state - process managers makes process to check if any new operations should be build according to process template. When all synchronous process operations are done - process finishes. Asynchronous operations or sub processes may stil be in progress. Automatic operations are may work in background using sidekiq.

Detailed documentation is in progress so please follow me on twitter [@max_madzhuga](https://twitter.com/max_madzhuga) if you interested.

## Operations
TBD

## Helpers
TBD

## Process Manager
TBD

## Process Template
TBD

## Operation Template
TBD

## Installation

Add to your application's Gemfile:

```ruby
gem 'rails_workflow', '0.2.0'
```

And then execute:

```sh
$ bundle install
```

Add to your config/application.rb
```ruby
require 'workflow'
```

and mount it to /workflow routes:
```ruby
Rails.application.routes.draw do
  ...
  mount Workflow::Engine => '/workflow', as: 'workflow'
  ...
end
```
Generate all models:
```sh
$ rails generate workflow:install
$ bundle exec rake db:migrate
```
Please check that your gemfile contains 'bootstrap-rails-engine', 'devise', 'will_paginate', 'sidekiq', 'slim-rails',
'inherited_resources', 'jquery-rails', 'jquery-ui-rails', 'draper'. Later I will remove some of that dependencies.
I will provide installation tutorial shortly.

## Configuration
TBD


## Processes configuration

## Processes management

## Process monitoring

## Errors monigoring and managing
Any error that happened during operation building or execution is saved. Operation and / or process is set to 'Error'
status. Administrator / support user can retry failed operation after fixing root cause of error.

[Here](http://madzhuga.tumblr.com/post/110449183244/rails-workflow-engine-exceptions-handling) you can read more about
exception handling in Rails Workflow.
