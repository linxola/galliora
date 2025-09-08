# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "donotreply#{ENV.fetch('DOMAIN')}"
  layout 'mailer'
end
