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

  belongs_to :default_wallet, class_name: 'Wallet', optional: true

  has_many :wallets, dependent: :restrict_with_exception
  has_many :wallet_shares, dependent: :restrict_with_exception
  has_many :shared_wallets, -> { active }, class_name: 'Wallet', through: :wallet_shares, source: :wallet
  has_many :wallet_share_invites_sent, class_name: 'WalletShareInvite', foreign_key: :wallet_owner_id,
           dependent: :restrict_with_exception, inverse_of: :wallet_owner
  has_many :wallet_share_invites_received, class_name: 'WalletShareInvite', inverse_of: :invitee,
           foreign_key: :invitee_email, primary_key: :email, dependent: :restrict_with_exception
  # rubocop:disable Rails/InverseOf
  has_many :active_wallets, -> { active }, class_name: 'Wallet', dependent: :restrict_with_exception
  # rubocop:enable Rails/InverseOf

  validates :email, presence: true, uniqueness: true
  validates :default_wallet, presence: true, unless: :new_record?

  validate :validate_email_in_allow_list

  after_save :set_default_wallet!

  def find_available_wallet(user_id)
    wallet = wallets.find_by(id: user_id) || shared_wallets.find_by(id: user_id)
    raise ActiveRecord::RecordNotFound unless wallet

    wallet
  end

  def as_json(attributes_only: false, **)
    json = super(except: %w[created_at updated_at], methods: %i[full_name display_name])
    json.merge(default_wallet: default_wallet.as_json) unless attributes_only
    json
  end

  def display_name
    first_name.presence || email
  end

  def full_name
    return email unless first_name.presence || last_name.presence

    [first_name, last_name].compact.join(' ')
  end

  def available_wallets
    (active_wallets + shared_wallets).uniq
  end

  private

  def validate_email_in_allow_list
    allow_list = Rails.application.credentials.user_email_allowlist
    return if allow_list.empty?
    return if allow_list.include?(email)

    errors.add(:base, :email_not_valid)
  end

  def set_default_wallet!
    return if default_wallet

    wallet = wallets.first || wallets.create(currency: initial_currency || :eur, status: :active)
    update!(default_wallet: wallet)
  end
end
