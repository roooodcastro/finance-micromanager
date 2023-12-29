# frozen_string_literal: true

class SystemMailer < ApplicationMailer
  def database_backup_created(backup_file_path)
    backup_file = File.read(backup_file_path)

    mail_headers = {
      subject: 'Finance Micromanager DB backup created',
      to:      Rails.application.credentials.default_email_from,
      body:    ''
    }

    attachments[File.basename(backup_file_path)] = backup_file

    mail(mail_headers)
  end
end
