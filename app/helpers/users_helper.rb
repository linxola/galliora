# frozen_string_literal: true

module UsersHelper
  def confirmation_email
    cookies.encrypted[:unconfirmed_email].presence || I18n.t('user.helpers.confirmation_email_nil')
  end
end
