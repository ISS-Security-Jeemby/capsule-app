# frozen_string_literal: true

require 'roda'
require_relative './app'

module TimeCapsule
  # Web controller for TimeCapsule API
  class App < Roda
    route('account') do |routing|
      routing.on do
        # GET /account/[username]
        routing.get String do |username|
          account_info = GetAccountDetails.new(App.config).call(
            @current_account, username
          )

          view :account, locals: { account: account_info }
        rescue GetAccountDetails::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/login'
        end

        # POST /account/<registration_token>
        routing.post String do |registration_token|
          passwords = Form::Passwords.new.call(routing.params)
          raise Form.message_values(passwords) if passwords.failure?

          new_account = SecureMessage.decrypt(registration_token)
          account_id = CreateAccount.new(App.config).call(
            email: new_account['email'],
            username: new_account['username'],
            password: routing.params['password']
          )

          # authenticate the current created account and get the auth_token
          authenticated = AuthenticateAccount.new(App.config)
                                             .call(
                                               username: new_account['username'],
                                               password: routing.params['password']
                                             )
          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token],
            account_id
          )

          # create capsules after creating account
          CreateCapsules.new(App.config).call(current_account:)
          flash[:notice] = 'Account created! Please login'
          routing.redirect '/auth/login'
        rescue CreateAccount::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/register'
        rescue StandardError => e
          flash[:error] = e.message
          routing.redirect(
            "#{App.config.APP_URL}/auth/register/#{registration_token}"
          )
        end
      end
    end
  end
end
