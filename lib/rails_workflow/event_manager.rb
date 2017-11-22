# frozen_string_literal: true

module RailsWorkflow
  # This manager controls events processing. Searches matching event operations
  # for a given event and merges event context to matched event operations.
  class EventManager
    class << self
      def create_event(tag, context = {})
        new(tag, context).handle
      end
    end

    def initialize(tag, context = {})
      @tag = tag
      @context = context
    end

    def handle
      event_operations.each do |event_operation|
        next if not_matches(event_operation)

        process_multiple_event(event_operation)
        event_operation.data.merge!(@context)
        event_operation.complete
      end
    end

    private

    def process_multiple_event(event_operation)
      return unless event_operation.multiple?

      new_event_operation = operation_builder.new(
        event_operation.process, event_operation.template, [event_operation]
      ).create_operation

      new_event_operation.start
    end

    def not_matches(event_operation)
      event_operation.respond_to?(:match) && !event_operation.match(@context)
    end

    def event_operations
      Operation.events.where(tag: @tag, status: Status::WAITING).all
    end

    # TODO: refactor all operation_builder, and other configuration methods
    def operation_builder
      config.operation_builder
    end

    def operation_runner
      config.operation_runner
    end

    def config
      RailsWorkflow.config
    end
  end
end
