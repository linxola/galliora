# frozen_string_literal: true

module UsersHelper
  def confirmations_email_field_value(resource)
    resource.pending_reconfirmation? ? resource.unconfirmed_email : resource.email
  end
end
