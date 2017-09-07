# frozen_string_literal: true

module RailsWorkflow
  class ProcessTemplateSerializer < ActiveModel::Serializer
    attributes :uuid, :title, :source,
               :manager_class, :process_class, :type,
               :partial_name, :version, :tag, :child_processes

    has_many :operations, serializer: RailsWorkflow::OperationTemplateSerializer

    def process_class
      object.read_attribute :process_class
    end

    def manager_class
      object.read_attribute :manager_class
    end

    def child_processes
      children = object.operations.map(&:child_process).compact.uniq
      unless children.blank?
        ActiveModel::ArraySerializer.new(
          children,
          each_serializer: ProcessTemplateSerializer
        ).as_json
      end || []
    end
  end
end
