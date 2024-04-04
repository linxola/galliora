# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    prepend_before_action :check_captcha, :configure_sign_in_params, only: [:create]
    before_action :check_user_confirmation, only: [:create]

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

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || user_path(current_user.id)
    end

    def after_sign_out_path_for(_resource)
      new_user_session_path
    end

    private

    def check_user_confirmation
      user = User.find_for_database_authentication(login: params[:user][:login])
      return if user.nil? || user.confirmed?

      cookies.encrypted[:unconfirmed_email] = { value: user.email, expires: 1.hour.from_now }
      user.send_confirmation_instructions
      redirect_to new_user_confirmation_path,
                  alert: I18n.t('devise.failure.inactive')
    end

    def check_captcha
      success = verify_recaptcha(action: 'login', minimum_score: 0.75,
                                 secret_key: ENV.fetch('RECAPTCHA_SECRET_KEY_V3'))
      unless success
        checkbox_success = verify_recaptcha(secret_key: ENV.fetch('RECAPTCHA_SECRET_KEY_V2'))
      end
      return if success || checkbox_success

      self.resource = resource_class.new sign_in_params
      @show_checkbox_recaptcha = true
      render :new, status: :unprocessable_entity
    end
  end
end
