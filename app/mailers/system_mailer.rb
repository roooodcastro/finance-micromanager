# frozen_string_literal: true

class SystemMailer < ApplicationMailer
  def database_backup_error(error)
    mail_headers = {
      subject: "Finance Micromanager DB backup could not be created: #{error.message}",
      to:      Rails.application.credentials.default_email_from,
      body:    error.detailed_message
    }

    mail(mail_headers)
  end
end
