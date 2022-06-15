# frozen_string_literal: true

require 'roda'
require_relative './app'

module TimeCapsule
  # Web controller for TimeCapsule API
  class App < Roda
    route('letters') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?

      routing.on(String) do |letter_id|
        # POST /letters/[letter_id]/collaborators
        routing.on('collaborators') do
          routing.post do
            action = routing.params['action']
            collaborator_info = Form::CollaboratorEmail.new.call(routing.params)
            if collaborator_info.failure?
              flash[:error] = Form.validation_errors(collaborator_info)
              routing.halt
            end
            NoticeCollaborator.new(App.config).call(@current_account, routing.params)
            task_list = {
              'add' => { service: AddCollaborator,
                         message: 'Added new collaborator to letter' },
              'remove' => { service: RemoveCollaborator,
                            message: 'Removed collaborator from letter' }
            }

            task = task_list[action]
            task_res = task[:service].new(App.config).call(
              current_account: @current_account,
              collaborator: collaborator_info,
              letter_id:
            )

            task_res.instance_of?(String) ? flash[:error] = task_res : flash[:notice] = task[:message]
            

          rescue StandardError
            flash[:error] = 'Could not find collaborator'
          ensure
            shared_capsule_id = GetAllCapsules.new(App.config).call(@current_account)[1]['attributes']['id']
            @shared_capsule_route = "/capsules/#{shared_capsule_id}"
            routing.redirect @shared_capsule_route
          end
        end

        # PUT /letters/[letter_id]
        routing.post do
          letter = UpdateLetter.new(App.config)
                               .call(@current_account, letter_id, routing.params)
          view :letter, locals: {
            current_account: @current_account, letter:
          }
        end

        # GET /letters/[letter_id]
        routing.get do
          letter_info = GetLetter.new(App.config)
                                 .call(@current_account, letter_id)
          letter = Letter.new(letter_info)
          view :letter, locals: {
            current_account: @current_account, letter:
          }
        end
      end
    end
  end
end
