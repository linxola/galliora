# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /check_email
    # def new
    #   super
    # end

    # POST /email_confirmation
    # def create
    #   super
    # end

    # GET /email_confirmation?confirmation_token=abcdef
    # def show
    #   super
    # end

    protected

    # The path used after resending confirmation instructions.
    def after_resending_confirmation_instructions_path_for(_resource_name)
      flash.notice = I18n.t('devise.confirmations.resend_instructions')
      new_user_confirmation_path
    end

    # The path used after confirmation.
    # def after_confirmation_path_for(resource_name, resource)
    #   super(resource_name, resource)
    # end
  end
end
