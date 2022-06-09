# frozen_string_literal: true

require 'http'

# Returns collaborators belonging to a letter
class GetLetterCollaborators
  def initialize(config)
    @config = config
  end

  def call(current_account, letter_id:)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/letters/#{letter_id}/collaborators")
    response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
  end
end
