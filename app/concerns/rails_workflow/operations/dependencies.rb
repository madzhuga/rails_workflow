# frozen_string_literal: true

require 'active_support/concern'

module RailsWorkflow
  module Operations
    # = Workflow::ProcessTemplate::Dependenceis
    #
    # Operation dependencies is a set of conditions. Operation can be build if all that
    # dependenceis / conditions are satisfied. This is default implementation of dependenceis
    # which used to build operation dependency on other operations. You can customize dependency
    # for example you can add some additional logic depending on existiong processes / operations
    # or other conditions in your system.
    #

    module Dependencies
      extend ActiveSupport::Concern

      included do
        serialize :dependencies, JSON

        # def dependencies=(dependencies)
        #   write_attribute(:dependencies, dependencies.to_json.to_s)
        # end
        #
        # def dependencies
        #   value = read_attribute(:dependencies)
        #   if value.present?
        #     JSON.parse(value)
        #   else
        #     []
        #   end
        # end
      end
    end
  end
end
