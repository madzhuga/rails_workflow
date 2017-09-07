# frozen_string_literal: true

class BadOperationTemplate < RailsWorkflow::OperationTemplate
  def build_operation(operation)
    # raise 'BUILD_OPERATION'
  end

  def resolve_dependency(_operation)
    # raise 'RESOLVE DEPENDENCY'
    true
  end
end
