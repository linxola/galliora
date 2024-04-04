# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    prepend_before_action :check_captcha, :configure_sign_up_params, only: [:create]
    prepend_before_action :configure_account_update_params, only: [:update]

    # GET /sign_up
    # def new
    #   super
    # end

    # POST /
    def create
      super
      cookies.encrypted[:unconfirmed_email] = { value: resource.email,
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
    def destroy
      if resource.destroy_with_password(account_destroy_params[:current_password])
        destroy_user(resource, resource_name)
      else
        set_flash_message! :alert, :destroy_failed
        resource.errors.clear
        render :edit, status: :unprocessable_entity
      end
    end

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

    def account_destroy_params
      params.require(:user).permit(:current_password)
    end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    def after_inactive_sign_up_path_for(_resource)
      new_user_confirmation_path
    end

    def after_update_path_for(_resource)
      edit_user_path
    end

    def after_sign_out_path_for(_resource)
      new_user_session_path
    end

    def update_resource(resource, params)
      # Require current password if user is trying to change password.
      return super if params['password'].present?

      # Allows user to update registration information without password.
      resource.update_without_password(params.except('current_password'))
    end

    private

    def check_captcha
      success = verify_recaptcha(action: 'registration', minimum_score: 0.75,
                                 secret_key: ENV.fetch('RECAPTCHA_SECRET_KEY_V3'))
      unless success
        checkbox_success = verify_recaptcha(secret_key: ENV.fetch('RECAPTCHA_SECRET_KEY_V2'))
      end
      return if success || checkbox_success

      self.resource = resource_class.new sign_up_params
      resource.validate and set_minimum_password_length
      @show_checkbox_recaptcha = true
      render :new, status: :unprocessable_entity
    end

    def destroy_user(resource, resource_name)
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message! :notice, :destroyed
      yield resource if block_given?
      respond_with_navigational(resource) do
        redirect_to after_sign_out_path_for(resource_name), status: Devise.responder.redirect_status
      end
    end
  end
end
