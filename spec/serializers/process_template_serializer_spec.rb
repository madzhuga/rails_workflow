# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe ProcessTemplateSerializer, type: :serializer do
    context 'Default Builder' do
      it 'should serialize child process' do
        process_template = create :process_template

        parent_operation_template = create :parent_operation_template
        process_template.operations << parent_operation_template
        process_template.save

        check = ProcessTemplateSerializer.new(process_template).as_json['process_template']
        child_process_uuid = check[:operations].first[:child_process]
        expect(check[:child_processes].map { |pt| pt[:uuid] }).to include(child_process_uuid)
      end

      it 'should not fail if no child processes' do
        process_template = create :process_template
        operation_template = create :operation_template

        process_template.operations << operation_template
        process_template.save

        check = ProcessTemplateSerializer.new(process_template).as_json['process_template']
        expect(check[:child_processes]).to be_blank
      end
    end
  end
end
