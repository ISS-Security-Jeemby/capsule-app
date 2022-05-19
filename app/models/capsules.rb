# frozen_string_literal: true

require_relative 'capsule'

module TimeCapsule
  # Behaviors of the currently logged in account
  class Capsules
    attr_reader :all

    def initialize(capsules_list)
      @all = capsules_list.map do |cap|
        Capsule.new(cap)
      end
    end
  end
end