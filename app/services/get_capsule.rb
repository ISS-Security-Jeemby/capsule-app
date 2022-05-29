# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Return a capsule of an account
  class GetCapsule
    def initialize(config)
      @config = config
    end

    def call(current_account, capsule_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/capsules/#{capsule_id}")

      binding.irb
      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end
