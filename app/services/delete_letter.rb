# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Return a capsule of an account
  class DeleteLetter
    def initialize(config)
      @config = config
    end

    def call(current_account, letter_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .delete("#{@config.API_URL}/letters/#{letter_id}")
      response.code == 200
    end
  end
end
