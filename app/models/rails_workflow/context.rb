module RailsWorkflow
  # Every operation and process has context. Context is a set of variables (by default it is a hash).
  # If you navigate to process you can see context data in right column:
  #
  # http://madzhuga.github.io/rails_workflow/images/process_context.png
  #
  # Navigate to operation and you will be able to see context in the bottom of the page:
  #
  # http://madzhuga.github.io/rails_workflow/images/operation_context.png
  #
  # When you create new process, you passing process template and initial context (hash) for that process:
  #
  #   RailsWorkflow::ProcessManager.start_process(
  #     process_template_id , { resource: resource }
  #   )
  #
  # Process manager takes process template and using it to build new process. It passing given context to template
  # and by default using it as is. You can change that behaviour using custom ProcessTemplate class.
  #
  # Operations context is build by operation template. By default operation template using process context (if operation
  # has no dependencies and is building before process start) or previous operations context.
  #
  #   Let's say we have process template with 3 operaiton templates: A, B, C. Operation template C depends on
  #   both operations A and B with DONE status. We have process build on that template with A and
  #   B operations. A is just get completed (changed it's status to DONE). But since operation B is IN_PROGRESS
  #   process not building operation C. Operaiton B is completed. Both A and B having DONE status so process starting
  #   to build operation C. By default it using last completed operation context. In our case it is B operation context
  #   but we have both operations A and B contexts passed to build_context method of OperationTemplate so you can easy
  #   change that behaviour and merge A and B contexts.
  #
  #   Please note: in given example operation C depends on both A and B with DONE status. Default operation template
  #   dependency resolver will build operation C if any of that operations will have DONE status. So in given example
  #   I assumed that operation C template has custom resolve_dependencies method which only return true if both operations
  #   exists in DONE status.
  #
  # @see RailsWorkflow::OperationTemplates::DefaultBuilder
  #
  class Context < ActiveRecord::Base
    belongs_to :parent, polymorphic: true

    # hash with operation context data
    attr_accessor :data

    # @private
    before_save :serialize_data

    # @private
    after_find :init_data

    # @private
    def serialize_data
      self.body = prepare_data(self.data)
    end

    # @private
    def init_data
      self.data = prepare_body(body).with_indifferent_access
    end

    # @private
    def prepare_body body
      if body.is_a? Array
        body.map do |element|
          prepare_body element
        end
      elsif body.is_a? Hash

        if body.keys == ["id", "class"]
          body["class"].constantize.find(body["id"])
        else
          res = {}
          body.each_pair do |key, value|
            res[key] = prepare_body(value)
          end
          res
        end

      else
        body
      end
    end

    # @private
    def prepare_data data
      if data.is_a? ActiveRecord::Base
        { id: data.id, class: data.class.to_s }
      elsif data.is_a? Array
        data.map do |element|
          prepare_data element
        end
      elsif data.is_a? Hash
        res = {}
        data.each_pair do |key, value|
          res[key] = prepare_data(value)
        end
        res
      else
        data
      end
    end

  end
end
