# frozen_string_literal: true

require 'roda'

module TimeCapsule
  # Web controller for TimeCapsule API
  class App < Roda
    route('letters') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?
      @shared_capsule_route = '/capsules/2'

      routing.on(String) do |letter_id|
        @letter_route = "#{@shared_capsule_route}/#{letter_id}"

        # GET /letters/[letter_id]
        routing.get do
          letter_info = GetLetter.new(App.config)
                                 .call(@current_account, letter_id)
          letter = Letter.new(letter_info)

          view :letter, locals: {
            current_account: @current_account, letter:
          }
        end

        # POST /letters/[letter_id]/collaborators
        routing.post('collaborators') do
          action = routing.params['action']
          collaborator_info = Form::CollaboratorEmail.new.call(routing.params)
          if collaborator_info.failure?
            flash[:error] = Form.validation_errors(collaborator_info)
            routing.halt
          end

          task_list = {
            'add' => { service: AddCollaborator,
                       message: 'Added new collaborator to letter' },
            'remove' => { service: RemoveCollaborator,
                          message: 'Removed collaborator from letter' }
          }

          task = task_list[action]
          task[:service].new(App.config).call(
            current_account: @current_account,
            collaborator: collaborator_info,
            letter_id:
          )
          flash[:notice] = task[:message]

        rescue StandardError
          flash[:error] = 'Could not find collaborator'
        ensure
          routing.redirect @letter_route
        end
      end
    end
  end
end
