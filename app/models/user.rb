# frozen_string_literal: true

class User < ApplicationRecord
  devise :registerable, :trackable
  devise :confirmable, reconfirmable: true, confirm_within: 24.hours
  devise :database_authenticatable, send_email_changed_notification: true, send_password_change_notification: true
  devise :lockable, maximum_attempts: 3, lock_strategy: :failed_attempts, unlock_strategy: :email
  devise :recoverable, reset_password_within: 1.hour
  devise :rememberable, extend_remember_period: true

  has_many :accounts, dependent: :restrict_with_exception

  validates :email, presence: true, uniqueness: true

  validate :validate_email_in_allow_list

  def validate_email_in_allow_list
    allow_list = Rails.application.credentials.user_email_allowlist
    return if allow_list.empty?
    return if allow_list.include?(email)

    errors.add(:base, :email_not_valid)
  end
end
