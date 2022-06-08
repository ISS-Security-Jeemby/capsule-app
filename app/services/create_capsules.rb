# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Create a new configuration file for a capsule
  class CreateCapsules
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:)
      config_url = "#{api_url}/capsules/#{current_account.id}/"
      response = HTTP.auth("Bearer #{current_account.auth_token}").post(config_url)
      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
