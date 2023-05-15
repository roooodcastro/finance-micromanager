# frozen_string_literal: true

class User < ApplicationRecord
  devise :registerable, :trackable
  devise :confirmable, reconfirmable: true, confirm_within: 24.hours
  devise :database_authenticatable, send_email_changed_notification: true, send_password_change_notification: true
  devise :lockable, maximum_attempts: 3, lock_strategy: :failed_attempts, unlock_strategy: :email
  devise :recoverable, reset_password_within: 1.hour
  devise :rememberable, extend_remember_period: true
end
