module RailsWorkflow
  # Rails Workflow engine using Process Templates to configure processes. Process template allows you to configure
  # future process operations and their dependencies. In addition to that it allows you to configure process itlesf.
  # If you will try to create new process template you will see following form:
  #
  # http://madzhuga.github.io/rails_workflow/images/new_process_template.png
  #
  # Here you can specify following process template parameters:
  #
  # Manager class - manager class is responsible for starting, building and completing process. It also may have
  # additional functions (for example broadcasting messages between processes) so you can specify some custom process
  # manager for your process or just use default one.
  #
  # Process class - responsible for starting, and stopping process, it's operations completion, resolving dependencies
  # (deciding if new operations should be build when existing process operations changins statuses). You can specify
  # some custom process class or use default.
  #
  # Type - process template class. Process Template class is responsible for building process and it's independent
  # operations. You can use some custom process template class here or just use default one.
  #
  # Here you can see process template operations list:
  # http://madzhuga.github.io/rails_workflow/images/first_tutorial_ready_template.png
  #
  #
  class ProcessTemplate < ActiveRecord::Base
    include ProcessTemplates::DefaultBuilder

    has_many :operations, :class_name => 'OperationTemplate'

    # @private
    def other_processes
      ProcessTemplate.where.not(id: self.id)
    end

    # @private
    def process_class
      get_class_for :process_class,
                    RailsWorkflow.config.process_class
    end

    # @private
    def manager_class
      get_class_for(:manager_class,
                    RailsWorkflow.config.manager_class)
    end

    # Independent operations is operations which has no dependencies. When default
    # builder (process template) is building process it also build independent operations
    # for that process. When process is starting - it also starts all operations which is
    # already exists in process (by default - independent operations)
    #
    # @return [Array<RailsWorkflow::OperationTemplates>]
    def independent_operations
      operations.independent_only.to_a
    end

    # Searches operation templates that depends on a given operation's template.
    # @param [RailsWorkflow::Operation] operation which template is used to search for dependent operations
    # @return [Array<RailsWorkflow::OperationTemplate>]
    def dependent_operations operation
      operations.select do |top|
        top.dependencies.select do |dp|
          dp['id'] == operation.template.id && dp['statuses'].include?(operation.status)
        end.present?
      end
    end

    private
    # @private
    def get_class_for symb, default
      (read_attribute(symb).presence || default).constantize
    end

  end
end
