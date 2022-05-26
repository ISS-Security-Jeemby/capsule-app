# frozen_string_literal: true

module TimeCapsule
  # Behaviors of the currently logged in account
  class Capsule
    attr_reader :id, :name, :type, # basic info
                :letters, :policies # full details

    def initialize(cap_info)
      @id = cap_info['data']['attributes']['id']
      @name = cap_info['data']['attributes']['name']
      @type = cap_info['data']['attributes']['type']
    end
  end
end
