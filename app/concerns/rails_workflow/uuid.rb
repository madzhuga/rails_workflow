module RailsWorkflow::Uuid
  extend ActiveSupport::Concern

  included do
    before_save :generate_guid
  end

  def generate_guid
    if uuid.blank?
      self.uuid = Guid.new.to_s
    end

  end
end
