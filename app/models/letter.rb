# frozen_string_literal: true

require_relative 'capsule'

module TimeCapsule
  # Behaviors of the currently logged in account
  class Letter
    attr_reader :id, :title, :receiver_id, :status, :is_private# basic info
                :content,
                :capsule # full details

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id             = attributes['id']
      @title          = attributes['title']
      @receiver_id    = attributes['receiver_id']
      @status         = attributes['status']
      @is_private     = attributes['is_private']
      @content        = attributes['content']
    end

    def process_included(included)
      @capsule = Capsule.new(included['capsule'])
    end
  end
end