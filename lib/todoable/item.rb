# frozen_string_literal: true

module Todoable
  class Item < Resource
    def self.path(list)
      base_url + 'lists/' + list.id + '/items'
    end

    def self.find(list, id)
      raise NotImplementedError.new("This endpoint does not exist!")
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
      raise InvalidRequestError.new("Requires a list and identifier.") unless list && id
      "#{self.class.path(list)}/#{id}"
    end

    # POST /lists/:list_id/items
    #
    # Creates an item for a given list
    def create
      raise TodoableError.new("Must be on new instance.") if id
      response = Todoable.client.post(self.class.path(list), build_payload)
      assign_attributes_from_response(response)
      list.items << self
      self
    end

    def update
      raise NotImplementedError.new("This endpoint does not exist!")
    end

    # DELETE /lists/:list_id/items/:item_id
    #
    # Deletes an item from a list
    def destroy
      Todoable.client.delete(path)
      list.items.delete(self)
      true
    end

    # PUT /lists/:list_id/items/:item_id/finish
    #
    # Marks an item as finished.
    def finish!
      Todoable.client.put("#{path}/finish")
      true
    end
  end
end
