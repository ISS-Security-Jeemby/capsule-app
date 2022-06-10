# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Return a capsule of an account
  class UpdateLetter
    def initialize(config)
      @config = config
    end

    def call(current_account, letter_id, letter_data, to_status = nil)
      letter_data['status'] = to_status.to_i if to_status
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .put("#{@config.API_URL}/letters/#{letter_id}", json: letter_data)
      response.code == 200 ? JSON.parse(response.body.to_s)['data']['data'] : nil
    end
  end
end
