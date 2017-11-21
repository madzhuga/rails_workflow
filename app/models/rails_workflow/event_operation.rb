# frozen_string_literal: true

module RailsWorkflow
  # Event operation - waiting/listening for some event.
  class EventOperation < Operation
    def can_start?
      false
    end

    # TODO: check if redundant
    def can_be_assigned?(_user)
      false # any user can complete operation
    end
  end
end
