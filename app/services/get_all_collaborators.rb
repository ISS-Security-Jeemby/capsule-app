# frozen_string_literal: true

require 'http'

# Returns all capsules belonging to an account
class GetAllCollaborators
  def initialize(config)
    @config = config
  end

  def call(current_account, letters:)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/letters/collaborators", json: letters)
    response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
  end
end
