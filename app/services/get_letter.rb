# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Return a capsule of an account
  class GetLetter
    def initialize(config)
      @config = config
    end

    def call(current_account, letter_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/letters/#{letter_id}")
      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end
