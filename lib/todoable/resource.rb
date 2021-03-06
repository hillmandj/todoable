# frozen_string_literal: true

module Todoable
  class Resource
    def self.base_url
      Todoable.configuration.base_url
    end

    def self.path
      raise NotImplementedError.new("#{self.name} is abstract.")
    end

    def self.find(id)
      response = Todoable.client.get("#{path}/#{id}")
      build_instance(id, response)
    end

    def self.destroy(id)
      new(id: id).destroy
    end

    def self.parse(response)
      JSON.parse(response.body, symbolize_names: true)
      # Rescuing here mainly because an Unauthorized response
      # comes back with an empty string as it's body.
    rescue JSON::ParserError => e
      {}
    end

    def self.build_instance(id, response)
      attributes = parse(response)
      self.new(attributes.merge(id: id))
    end

    def path
      raise InvalidRequestError.new("Please pass an identifier.") unless id
      "#{self.class.path}/#{id}"
    end

    def create
      raise TodoableError.new("Must be on new instance.") if id
      response = Todoable.client.post(self.class.path, build_payload)
      assign_attributes_from_response(response)
      self
    end

    def update
      response = Todoable.client.patch(path, build_payload)
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
        value = as_json.select { |k, _| k == :name } # only sending :name for now
        hash[key] = value
      end

      JSON.generate(payload)
    end

    def assign_attributes_from_response(response)
      self.class.parse(response).each do |attribute, value|
        self.send("#{attribute}=", value)
      end
    end
  end
end
