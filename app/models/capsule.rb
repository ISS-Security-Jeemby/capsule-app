# frozen_string_literal: true

module TimeCapsule
    # Behaviors of the currently logged in account
    class Capsule
      attr_reader :id, :name, :type
  
      def initialize(proj_info)
        @id = proj_info['attributes']['id']
        @name = proj_info['attributes']['name']
        @repo_url = proj_info['attributes']['type']
      end
    end
  end