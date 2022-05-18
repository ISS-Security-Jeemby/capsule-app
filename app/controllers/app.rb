# frozen_string_literal: true

require 'roda'
require 'slim'

module TimeCapsule
  # Base class for Capsule Web Application
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :public, root: 'app/presentation/public'
    plugin :multi_route
    plugin :flash

    route do |routing|
      response['Content-Type'] = 'text/html; charset=utf-8'
      @current_account = CurrentSession.new(session).current_account

      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        # test: get all capsules if an account logged in
        GetAllCapsules.new(App.config).call(@current_account) if @current_account.logged_in?
        view 'home', locals: { current_account: @current_account }
      end
    end
  end
end
