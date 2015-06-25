module RailsWorkflow
  class ProcessTemplateSerializer < ActiveModel::Serializer
    attributes :uuid, :title, :source,
               :manager_class, :process_class, :type,
               :partial_name, :version, :tag

    has_many :operations, serializer: RailsWorkflow::OperationTemplateSerializer


    def process_class
      object.read_attribute :process_class
    end

    def manager_class
      object.read_attribute :manager_class
    end
  end
end
