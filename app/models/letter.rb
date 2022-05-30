# frozen_string_literal: true

require_relative 'capsule'

module TimeCapsule
  # Behaviors of the currently logged in account
  class Letter
    attr_reader :id, :title, :receiver_id, :status, :is_locked, :is_private, # basic info
                :content

    def initialize(info)
      process_attributes(info['attributes'])
    end

    private

    def process_attributes(attributes)
      @id             = attributes['id']
      @title          = attributes['title']
      @receiver_id    = attributes['receiver_id']
      @status         = attributes['status']
      @is_locked      = attributes['is_locked']
      @is_private     = attributes['is_private']
      @content        = attributes['content']
    end
  end
end
