# frozen_string_literal: true

require_relative 'capsule'

module TimeCapsule
  # Behaviors of the currently logged in account
  class Letter
    attr_reader :id, :title, :receiver_id, :status, :is_locked, :is_private, :content # basic info

    def initialize(info)
      process_attributes(info['attributes'])
      process_relationships(info['relationships'])
      process_policies(info['policies'])
    end

    private

    def process_attributes(attributes)
      @id             = attributes['id']
      @title          = attributes['title']
      @receiver_id    = attributes['receiver_id']
      @status         = attributes['status']
      @send_at        = attributes['send_at']
      @open_at        = attributes['open_at']
      @created_at     = attributes['created_at']
      @is_locked      = attributes['is_locked']
      @is_private     = attributes['is_private']
      @content        = attributes['content']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @collaborators = process_collaborators(relationships['collaborators'])
      @documents = process_documents(relationships['documents'])
    end

    def process_policies(policies)
      @policies = Struct.new(policies)
    end

    def process_collaborators(collaborators)
      return nil unless collaborators

      collaborators.map { |account_info| Account.new(account_info) }
    end
  end
end
