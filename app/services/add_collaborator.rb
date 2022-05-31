# frozen_string_literal: true

module TimeCapsule
  # Service to add collaborator to project
  class AddCollaborator
    class CollaboratorNotAdded < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, collaborator:, letter_id:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{api_url}/letters/#{letter_id}/collaborators",
                           json: { email: collaborator[:email] })
      raise CollaboratorNotAdded unless response.code == 200

      JSON.parse(response.to_s)['data']
    end
  end
end
