# frozen_string_literal: true

module RailsWorkflow
  class Context < ActiveRecord::Base
    belongs_to :parent, polymorphic: true
    attr_accessor :data

    serialize :body, JSON

    before_save :serialize_data
    after_find :init_data

    def serialize_data
      self.body = prepare_data(data)
    end

    def init_data
      self.data = prepare_body(body).with_indifferent_access
    end

    def prepare_body(body)
      if body.is_a? Array
        body.map do |element|
          prepare_body element
        end
      elsif body.is_a? Hash

        if body.keys == %w[id class]
          body['class'].constantize.find(body['id'])
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

    def prepare_data(data)
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
