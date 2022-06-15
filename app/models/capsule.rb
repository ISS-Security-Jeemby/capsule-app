# frozen_string_literal: true

module TimeCapsule
  # Behaviors of the currently logged in account
  class Capsule
    attr_reader :id, :name, :type, # basic info
                :owner, :collaborated_letters, :owned_letters, :policies # full details

    def initialize(cap_info)
      process_attributes(cap_info['attributes'])
      process_relationships(cap_info['relationships'])
      process_policies(cap_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @name = attributes['name']
      @type = attributes['type']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @collaborators = process_collaborators(relationships['collaborated_letters'])
      @documents = process_letters(relationships['owned_letters'])
    end

    def process_policies(policies)
      return unless policies

      @policies = Struct.new(policies)
    end

    def process_letters(letters_info)
      return nil unless letters_info

      letters_info.map { |letter_info| Document.new(letter_info) }
    end

    def process_collaborators(collaborators)
      return nil unless collaborators

      collaborators.map { |account_info| Account.new(account_info) }
    end
  end
end
