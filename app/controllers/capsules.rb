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
          routing.on 'letters' do
            routing.on('status') do
              routing.on(String) do |to_status|
                # PUT capsules/[capsule_id]/letters/status/[to_status]
                routing.post do
                  letter_id = routing.params['id']
                  routing.params.delete('id')
                  letter = UpdateLetter.new(App.config)
                                      .call(@current_account, letter_id, routing.params, to_status)
                  routing.redirect @capsule_route
                end
              end
            end

            routing.on String do |letter_id|
              # PUT capsules/[capsule_id]/letters/[letter_id]
              routing.post do
                letter = UpdateLetter.new(App.config)
                                     .call(@current_account, letter_id, routing.params)
                view :letter, locals: {
                  current_account: @current_account, letter:
                }
                routing.redirect @capsule_route
              end

              # GET capsules/[capsule_id]/letters/[letter_id]
              routing.get do
                letter = GetLetter.new(App.config)
                                  .call(@current_account, letter_id)
                collaborators = GetLetterCollaborators.new(App.config).call(
                  @current_account, letter_id:
                )
                capsule = GetCapsule.new(App.config)
                                    .call(@current_account, capsule_id)

                view :letter, locals: {
                  current_account: @current_account, letter:, capsule: capsule['attributes'], collaborators:
                }
              end
            end

            # POST /capsules/[capsule_id]/letters/
            routing.post do
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
              puts e.full_message
              flash[:error] = 'Could not add letter'
            ensure
              routing.redirect @capsule_route
            end
          end

          # GET /capsules/[capsule_id]
          routing.get do
            # get capsule infor
            capsule_info = GetCapsule.new(App.config).call(
              @current_account, capsule_id
            )
            capsule = Capsule.new(capsule_info)

            # get letters
            letters = GetCapsuleLetters.new(App.config).call(
              @current_account, capsule_id
            )
            status_code = { 1 => 'Draft', 2 => 'Sended', 3 => 'Reciever Recieved' }
            letters.each do |letter|
              letter['attributes']['status'] = status_code[letter['attributes']['status']]
            end

            # get collaborators
            collaborators = GetAllCollaborators.new(App.config).call(
              @current_account, letters:
            )

            view :capsule, locals: {
              current_account: @current_account, capsule:, letters:, collaborators:
            }
          rescue StandardError => e
            puts e.full_message
            flash[:error] = 'Capsule not found'
            routing.redirect @capsules_route
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
