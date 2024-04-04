# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def github
      authenticate('GitHub')
    end

    def google_oauth2
      authenticate('Google')
    end

    # GET|POST /resource/auth/twitter
    # def passthru
    #   super
    # end

    # GET|POST /users/auth/twitter/callback
    # def failure
    #   super
    # end

    # protected

    # The path used when OmniAuth fails
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end

    private

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || user_path(current_user.id)
    end

    def authenticate(provider)
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
        sign_in_and_redirect @user, event: :authentication
      else
        set_flash_message(:alert, :failure_creating, kind: provider)
        redirect_to new_user_session_path
      end
    end
  end
end
