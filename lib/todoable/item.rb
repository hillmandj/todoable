# frozen_string_literal: true

module Todoable
  class Item < Resource
    def self.path(list)
      base_url + 'lists/' + list.id + '/items'
    end

    def self.find(list, id)
      response = Todoable.client.get("#{path(list)}/#{id}")
      build_instance(id, response)
    end

    def self.destroy(list, id)
      new(list: list, id: id).destroy
    end

    attr_accessor :id, :name, :src, :finished_at, :list

    def initialize(list: nil, id: nil, name: nil, src: nil, finished_at: nil)
      @id = id
      @src = src
      @name = name
      @list = list
      @finished_at = finished_at
    end

    def path
      raise(InvalidRequestError, "Please pass an identifiers") unless list && id
      "#{self.class.path(list)}/#{id}"
    end

    def create
      raise InvalidRequestError.new("Must be on new instance.") if id
      response = Todoable.client.post(self.class.path(list), build_payload)
      assign_attributes_from_response(response)
      self
    end

    def destroy
      Todoable.client.delete(path)
      list.items.delete(self)
      true
    end

    def finish!
      Todoable.client.put("#{path}/finish")
      true
    end
  end
end
