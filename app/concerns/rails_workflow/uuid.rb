# frozen_string_literal: true

module RailsWorkflow::Uuid
  extend ActiveSupport::Concern

  included do
    before_save :generate_guid
  end

  def generate_guid
    self.uuid = Guid.new.to_s if uuid.blank?
  end
end
