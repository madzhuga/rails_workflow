module RailsWorkflow
  class ProcessImporter
    def initialize(json)
      prepared_json = RailsWorkflow.config.import_preprocessor.prepare(json)
      @json = prepared_json['process_template']
    end

    def process
      process = ProcessTemplate
                .where(uuid: @json['uuid']).first_or_create!

      @json['child_processes'] && @json['child_processes'].each do |child_process|
        ProcessImporter.new('process_template' => child_process).process
      end

      process.attributes = @json.except('operations', 'child_processes')
      process.save

      operations = []
      ids_to_delete = process.operations.pluck(:id)

      @json['operations'].each do |operation_json|
        operation = process
                    .operations.where(uuid: operation_json['uuid']).first_or_create!

        operation.attributes = operation_json.except('child_process')
        if operation_json['child_process'].present?
          child_template = ProcessTemplate.find_by_uuid(operation_json['child_process'])
          raise ActiveRecord::RecordNotFound, "Operation #{operation.title} child process template not found by UUID" if child_template.blank?
          operation.child_process = child_template
        end
        operation.save

        ids_to_delete.delete(operation.id)
        operations << operation
      end

      OperationTemplate.delete(ids_to_delete) if ids_to_delete.present?

      operations.each do |operation|
        operation.dependencies.each do |d|
          d['id'] = OperationTemplate
                    .find_by_uuid(d['uuid']).try(:id)

          d.delete('uuid')
        end

        operation.save
      end
    end
  end
end
