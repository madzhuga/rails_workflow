# frozen_string_literal: true

module RailsWorkflow
  # Default error builder. Can be changed in configuration.
  # Manages errors building
  class ErrorBuilder
    attr_accessor :exception, :context

    def self.handle(exception, context)
      new(exception, context).handle
    end

    def initialize(exception, context)
      @exception = exception
      @context = context
    end

    def handle
      create_error(context)
      process_parent(target)
    end

    private

    def create_error(context)
      error = RailsWorkflow::Error.create(
        parent: target,
        message: exception.message.first(250),
        stack_trace: exception.backtrace.join("<br/>\n")
      )

      error.create_context(data: context)
    end

    # Changing custom process or operation classes to default classes.
    # If we store error with a custom class and somebody will delete
    # or rename this class - we will not be able to load error.
    def target
      @target ||= begin
        parent = context[:parent]
        if parent.is_a? RailsWorkflow::Operation
          parent.becomes(RailsWorkflow::Operation)
        elsif parent.is_a? RailsWorkflow::Process
          parent.becomes(RailsWorkflow::Process)
        end
      end
    end

    def process_parent(subject)
      return if subject.nil?

      subject.status = Status::ERROR
      subject.save
      process_parent(subject.parent) if subject.parent.present?
    end
  end
end
