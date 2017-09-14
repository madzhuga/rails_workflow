## 0.4.0
    * Error management improvements (added ErrorBuilder, can be configured)
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
