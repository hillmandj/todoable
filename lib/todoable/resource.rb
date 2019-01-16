# frozen_string_literal: true

module Todoable
  class Resource
    def self.base_url
      Todoable.configuration.base_url
    end

    def self.path
      raise(NotImplementedError, "#{self.name} is abstract. Please refer to #{subclasses}")
    end

    def self.find(id)
      response = Todoable.client.get("#{path}/#{id}")
      build_instance(id, response)
    end

    def self.create(params)
      new(params).create
    end

    def self.destroy(id)
      new(id: id).destroy
    end

    def self.parse(response)
      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError => e
      {}
    end

    # Helper method for instantiating objects based on response.
    # id is passed since it is not guaranteed.
    def self.build_instance(id, response)
      attributes = parse(response)
      self.new(attributes.merge(id: id))
    end

    def path
      raise TodoableError.new("Please pass an identifier.") unless id
      "#{self.class.path}/#{id}"
    end

    def create
      raise InvalidRequestError.new("Must be on new instance.") if id
      response = Todoable.client.post(self.class.path, build_payload)
      assign_attributes_from_response(response)
      self
    end

    def update(params)
      response = Todoable.client.put(path, params)
      assign_attributes_from_response(response)
      self
    end

    def destroy
      Todoable.client.delete(path)
      true
    end

    def as_json
      instance_variables.each_with_object({}) do |attribute, hash|
        key = attribute.to_s.delete('@').to_sym
        value = instance_variable_get(attribute)
        hash[key] = value
      end
    end

    private

    def build_payload
      payload = {}.tap do |hash|
        key = self.class.name.split('::').last.downcase.to_sym
        value = as_json.tap { |h| h.delete(:id) }
        hash[key] = value
      end

      JSON.generate(payload)
    end

    def assign_attributes_from_response(response)
      self.class.parse(response).each { |attr, value| self.send("#{attr}=", value) }
    end
  end
end
