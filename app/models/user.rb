# frozen_string_literal: true

class User < ApplicationRecord
  self.implicit_order_column = :created_at

  devise :registerable, :trackable
  devise :confirmable, reconfirmable: true, confirm_within: 24.hours
  devise :database_authenticatable, send_email_changed_notification: true, send_password_change_notification: true
  devise :lockable, maximum_attempts: 3, lock_strategy: :failed_attempts, unlock_strategy: :email
  devise :recoverable, reset_password_within: 1.hour
  devise :rememberable, extend_remember_period: true

  attr_accessor :initial_currency

  belongs_to :default_account, class_name: 'Account', optional: true

  has_many :accounts, dependent: :restrict_with_exception
  has_many :account_users, dependent: :restrict_with_exception
  # rubocop:disable Rails/InverseOf
  has_many :active_accounts, -> { active }, class_name: 'Account', dependent: :restrict_with_exception
  # rubocop:enable Rails/InverseOf

  has_many :shared_accounts, -> { active }, class_name: 'Account', through: :account_users, source: :account

  validates :email, presence: true, uniqueness: true
  validates :default_account, presence: true, unless: :new_record?

  validate :validate_email_in_allow_list

  after_save :set_default_account!

  def find_available_account(user_id)
    account = accounts.find_by(id: user_id) || shared_accounts.find_by(id: user_id)
    raise ActiveRecord::RecordNotFound unless account

    account
  end

  def as_json(*)
    super.merge(default_account: default_account.as_json)
  end

  def available_accounts
    (active_accounts + shared_accounts).uniq
  end

  private

  def validate_email_in_allow_list
    allow_list = Rails.application.credentials.user_email_allowlist
    return if allow_list.empty?
    return if allow_list.include?(email)

    errors.add(:base, :email_not_valid)
  end

  def set_default_account!
    return if default_account

    account = accounts.first || accounts.create(currency: initial_currency || :eur, status: :active)
    update!(default_account: account)
  end
end
