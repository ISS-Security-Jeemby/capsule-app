# frozen_string_literal: true

require 'roda'

module TimeCapsule
  # Web controller for TimeCapsule API
  class App < Roda
    route('capsules') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @capsules_route = '/capsules'

        routing.on(String) do |capsule_id|
          @capsule_route = "#{@capsules_route}/#{capsule_id}"

          # GET /capsules/[capsule_id]
          routing.get do
            binding.irb
            capsule_info = GetCapsule.new(App.config).call(
              @current_account, capsule_id
            )
            capsule = Capsule.new(capsule_info) # Question
            view :capsule, locals: {
              current_account: @current_account, capsule:
            }
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Capsule not found'
            routing.redirect @capsules_route
          end

          # POST /capsules/[capsule_id]/letters/
          routing.post('letters') do
            letter_data = Form::NewLetter.new.call(routing.params)
            if letter_data.failure?
              flash[:error] = Form.message_values(letter_data)
              routing.halt
            end

            CreateNewLetter.new(App.config).call(
              current_account: @current_account,
              capsule_id:,
              letter_data: letter_data.to_h
            )

            flash[:notice] = 'Your letter was added'
          rescue StandardError => e
            puts e.inspect
            puts e.backtrace
            flash[:error] = 'Could not add letter'
          ensure
            routing.redirect @capsule_route
          end
        end

        # GET /capsules/
        routing.get do
          capsule_list = GetAllCapsules.new(App.config).call(@current_account)
          capsules = Capsules.new(capsule_list)
          view :capsules_all, locals: {
            current_user: @current_account, capsules:
          }
        end
      end
    end
  end
end
