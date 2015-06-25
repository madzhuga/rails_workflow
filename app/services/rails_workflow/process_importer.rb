module RailsWorkflow
  class ProcessImporter
    def initialize json
      @json = json['process_template']
    end

    def process
      process = ProcessTemplate.
          where(uuid: @json['uuid']).first_or_create!

      process.attributes = @json.except('operations')
      process.save

      operations = []
      ids_to_delete = process.operations.pluck(:id)

      @json['operations'].each do |operation_json|

        operation = process.
            operations.where(uuid: operation_json['uuid']).first_or_create!

        operation.attributes = operation_json
        operation.save

        ids_to_delete.delete(operation.id)
        operations << operation
      end


      OperationTemplate.delete(ids_to_delete) if ids_to_delete.present?


      operations.each do |operation|
        operation.dependencies.each do |d|
          d['id'] = OperationTemplate.
              find_by_uuid(operation['uuid']).try(:id)

          d.delete("uuid")
        end

        operation.save
      end


    end
  end
end

