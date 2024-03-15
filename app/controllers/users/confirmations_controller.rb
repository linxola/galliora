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
    def show # rubocop:disable Metrics/AbcSize
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if resource.errors.empty?
        set_flash_message!(:notice, :confirmed)
      else
        flash.alert = resource.errors.full_messages.last
      end

      respond_with_navigational(resource) do
        redirect_to after_confirmation_path_for(resource_name, resource)
      end
    end

    protected

    # The path used after resending confirmation instructions.
    def after_resending_confirmation_instructions_path_for(_resource_name)
      flash.notice = I18n.t('devise.confirmations.send_instructions')
      new_user_confirmation_path
    end

    # The path used after confirmation.
    # def after_confirmation_path_for(resource_name, resource)
    #   super(resource_name, resource)
    # end
  end
end
