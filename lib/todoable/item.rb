# frozen_string_literal: true

module Todoable
  class Item < Resource
    def self.path(list)
      base_url + 'lists/' + list.id + '/items'
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
      raise(InvalidRequestError, "Please pass an identifier") unless list && id
      self.class.path(list) + id
    end

    def finish!
      current_time = Time.now
      update(finished_at: current_time)
      finished_at = current_time
      self
    end
  end
end
