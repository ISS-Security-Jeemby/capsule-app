# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Create a new configuration file for a capsule
  class CreateNewLetter
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, capsule_id:, letter_data:)
      config_url = "#{api_url}/capsules/#{capsule_id}/letters"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, json: letter_data)
      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
