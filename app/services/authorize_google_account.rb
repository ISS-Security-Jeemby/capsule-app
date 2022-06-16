# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Returns an authenticated user, or nil
  class AuthorizeGoogleAccount
    class ReuseEmailError < StandardError; end

    # Errors emanating from Google
    class UnauthorizedError < StandardError
      def message
        'Could not login with Google'
      end
    end

    def initialize(config)
      @config = config
    end

    def call(code)
      access_token = get_access_token_from_google(code)
      get_googlesso_account_from_api(access_token)
    end

    private

    # rubocop:disable Style/HashSyntax
    def get_access_token_from_google(code)
      challenge_response =
        HTTP.headers(accept: 'application/json')
            .post(@config.GO_TOKEN_URL,
                  form: { client_id: @config.GO_CLIENT_ID,
                          client_secret: @config.GO_CLIENT_SECRET,
                          grant_type: 'authorization_code',
                          redirect_uri: "#{@config.APP_URL}/auth/google-callback",
                          code: code })
      raise UnauthorizedError unless challenge_response.status == 200

      JSON.parse(challenge_response)['access_token']
    end

    def get_googlesso_account_from_api(access_token)
      signed_google_sso_info = { access_token: }
                               .then { |sso_info| SignedMessage.sign(sso_info) }

      response = HTTP.post(
        "#{@config.API_URL}/auth/google_sso",
        json: signed_google_sso_info
      )
      raise(ReuseEmailError) if response.code == 400
      raise(UnauthorizedError) unless response.code == 200

      account_info = JSON.parse(response)['data']['attributes']
      {
        account: account_info['account'],
        auth_token: account_info['auth_token'],
        account_id: account_info['account_id'],
        is_register: account_info['is_register']
      }
    end
    # rubocop:enable Style/HashSyntax
  end
end
