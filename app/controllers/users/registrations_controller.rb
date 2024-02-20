# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    before_action :configure_account_update_params, only: [:update] # rubocop:disable Rails/LexicallyScopedActionFilter

    # GET /sign_up
    # def new
    #   super
    # end

    # POST /
    def create
      super
      cookies.encrypted[:unconfirmed_email] = { value: params[:user][:email],
                                                expires: 1.hour.from_now }
      flash.clear
    end

    # GET /edit
    # def edit
    #   super
    # end

    # PUT /
    # def update
    #   super
    # end

    # DELETE /
    # def destroy
    #   super
    # end

    # GET /cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[username email password])
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: %i[username name about email
                                                                  current_password password])
    end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    def after_inactive_sign_up_path_for(_resource)
      new_user_confirmation_path
    end
  end
end
