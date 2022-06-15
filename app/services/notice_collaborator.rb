# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Returns an authenticated user, or nil
  class NoticeCollaborator
    class VerificationError < StandardError; end
    class ReuseEmailOrUsernameError < StandardError; end
    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(current_account,collaborator_data)
      # collaborator_token = SecureMessage.encrypt(collaborator_data)
      
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{@config.API_URL}/letters/notice", json: collaborator_data)
      
      raise(ReuseEmailOrUsernameError) if response.code == 400
      raise(VerificationError) unless response.code == 202  

      JSON.parse(response.to_s)
    rescue HTTP::ConnectionError
      raise(ApiServerError)
    end
  end
end