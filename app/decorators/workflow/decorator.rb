module Workflow
  class Decorator < Draper::Decorator
    def self.collection_decorator_class
      PaginatingDecorator
    end
  end
end
