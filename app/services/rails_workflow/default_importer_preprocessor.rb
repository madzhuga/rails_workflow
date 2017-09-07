# frozen_string_literal: true

module RailsWorkflow
  class DefaultImporterPreprocessor
    def prepare(json)
      if json['operations']
        json['process_template']['operations'] = json['operations']
        json['process_template'].delete('operation_ids')
      end

      json
    end
  end
end
