# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action :configure_sign_in_params, :check_user_confirmation, only: [:create]

    # GET /sign_in
    # def new
    #   super
    # end

    # POST /sign_in
    # def create
    #   super
    # end

    # DELETE /sign_out
    # def destroy
    #   super
    # end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: %i[login password])
    end

    def check_user_confirmation
      user = User.find_for_database_authentication(login: params[:user][:login])
      return if user&.confirmed?

      cookies.encrypted[:unconfirmed_email] = { value: user.email, expires: 1.hour.from_now }
      user.send_confirmation_instructions
      redirect_to new_user_confirmation_path,
                  alert: I18n.t('user.flashes.confirmation_needed_before_login')
    end
  end
end
