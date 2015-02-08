class BadOperation < Workflow::Operation
  def on_complete
    # raise 'ON_COMPLETE EXCEPTION'
  end

  def execute
    # raise 'EXECUTE EXCEPTION'
    true
  end

end