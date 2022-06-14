# frozen_string_literal: true

require_relative './app'
require 'roda'
require 'rack/ssl-enforcer'
require 'rack/session/redis'
require 'secure_headers'

module Credence
  # Configuration for the API
  class App < Roda
    plugin :environments
    plugin :multi_route

    FONT_SRC = %w[https://maxcdn.bootstrapcdn.com].freeze
    SCRIPT_SRC = %w[https://code.jquery.com
                    https://maxcdn.bootstrapcdn.com].freeze
    STYLE_SRC = %w[https://maxcdn.bootstrapcdn.com
                   https://cdnjs.cloudflare.com].freeze

    configure :production do
      use Rack::SslEnforcer, hsts: true
    end
    ## Uncomment to drop the login session in case of any violation
    # use Rack::Protection, reaction: :drop_session
    use SecureHeaders::Middleware

    SecureHeaders::Configuration.default do |config|
      config.cookies = {
        secure: true,
        httponly: true,
        samesite: {
          strict: true
        }
      }

      config.x_frame_options = 'DENY'
      config.x_content_type_options = 'nosniff'
      config.x_xss_protection = '1'
      config.x_permitted_cross_domain_policies = 'none'
      config.referrer_policy = 'origin-when-cross-origin'

      # NOTE: single-quotes needed around 'self' and 'none' in CSPs
      # rubocop:disable Lint/PercentStringArray
      config.csp = {
        report_only: false,
        preserve_schemes: true,
        default_src: %w['self'],
        child_src: %w['self'],
        connect_src: %w[wws:],
        img_src: %w['self'],
        font_src: %w['self'] + FONT_SRC,
        script_src: %w['self'] + SCRIPT_SRC,
        style_src: %W['self' 'unsafe-inline'] + STYLE_SRC,
        form_action: %w['self'],
        frame_ancestors: %w['none'],
        object_src: %w['none'],
        block_all_mixed_content: true,
        report_uri: %w[/security/report_csp_violation]
      }
      # rubocop:enable Lint/PercentStringArray
    end

    route('security') do |routing|
      # POST security/report_csp_violation
      routing.post 'report_csp_violation' do
        puts "CSP VIOLATION: #{request.body.read}"
      end
    end
  end
end
