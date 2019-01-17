# frozen_string_literal: true

module Todoable
  class List < Resource
    def self.path
      base_url + 'lists'
    end

    # GET /lists
    #
    # Returns an array of List objects
    def self.all
      response = Todoable.client.get(path)
      parsed_body = parse(response)[:lists] || []
      parsed_body.map { |attrs| List.new(attrs) }
    end

    attr_accessor :id, :name, :src, :items

    def initialize(id: nil, name: nil, src: nil, items: [])
      @id = id
      @src = src
      @name = name
      @items = build_item_objects(items)
    end

    def add_item(name)
      item = Item.new(list: self, name: name)
      @items << item.create
    end

    private

    def build_item_objects(items)
      items.map { |attrs| Item.new(attrs.merge(list: self)) }
    end
  end
end
