# frozen_string_literal: true

require_relative 'form_base'

module TimeCapsule
  module Form
    # Form validation for a new letter
    class NewLetter < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_letter.yml')

      params do
        required(:title).filled(max_size?: 256, format?: FILENAME_REGEX)
        required(:content).filled(:string)
        required(:receiver_id).maybe(:string)
      end
    end
  end
end
