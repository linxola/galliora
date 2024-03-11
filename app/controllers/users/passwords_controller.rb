# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    # GET /password/new
    # def new
    #   super
    # end

    # POST /password
    # def create
    #   super
    # end

    # GET /password/edit?reset_password_token=abcdef
    # def edit
    #   super
    # end

    # PUT /password
    # def update
    #   super
    # end

    protected

    # def after_resetting_password_path_for(resource)
    #   super(resource)
    # end

    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(_resource_name)
      flash.notice = I18n.t('devise.passwords.send_instructions')
      new_user_password_path
    end
  end
end
