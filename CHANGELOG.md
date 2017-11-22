## 0.7.1
  * STI bug in events manager fix
## 0.7.0
  * Events support
## 0.4.4
  * Process, operation and error context improvement (save context after operation saved)
## 0.4.3
  * Tag field added to operation template view
  * Misc bug fixes
## 0.4.2
  * Fix rails dependencies (now can be used with Rails 5 applications)
  * Fix operation template decorator (failed if user model has no groups and roles)
## 0.4.1
  * Too long index names issue in non-Postgres databases fix
## 0.4.0
  * General code improvements - split bulders, runners, resolvers and other
    models from application records.
  * Removed OperationErrorJob (errors no longer processed in separate
    background job)
  * Removed pg from gem dependencies
  * Added Rubocop
## 0.3.9
    * added Active Job API support instead of hard-coded sidekiq.
## 0.3.7
    * added import template preprocessor
## 0.3.5
    * fixed assets precompilation
    * independent operations fix
## 0.3.2
    * Fixes to mysql support - removed uuid and moved window functions to pg dialect to support mysql
## 0.3.1
    * Removed native json database type dependency to allow MySQL and other DBs not having native json data type
## 0.3.0:
    * configuration export / import
    * Custom context view for operations (can be specified on operation templates)
    * removed dependency from inherited_resources
    * removed dependency from devise
    * fixed rails version
    * fixed jquery version
