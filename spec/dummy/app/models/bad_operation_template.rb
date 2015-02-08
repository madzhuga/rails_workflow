class BadOperationTemplate < Workflow::OperationTemplate
  def build_operation operation
    # raise 'BUILD_OPERATION'
  end


  def resolve_dependency operation
    # raise 'RESOLVE DEPENDENCY'
    true
  end

end