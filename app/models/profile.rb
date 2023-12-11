# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :default_wallet, class_name: 'Wallet', optional: true

  has_many :transactions, dependent: :restrict_with_exception
  has_many :categories, dependent: :restrict_with_exception
  has_many :imports, dependent: :restrict_with_exception
  has_many :profile_shares, dependent: :restrict_with_exception
  has_many :wallets, dependent: :restrict_with_exception

  has_many :shared_users, class_name: 'User', through: :profile_shares, source: :user

  scope :shared_with, ->(user) { left_joins(:profile_shares).where(profile_shares: { user: }) }

  enum status: { active: 'active', disabled: 'disabled' }

  validates :status, presence: true
  validates :currency, presence: true, inclusion: { in: Money::Currency.map(&:id).map(&:to_s) }
  validates :name, length: { maximum: 30 }, allow_blank: true

  validate :validate_currency_stays_the_same

  def as_json(*)
    currency_as_json = currency_object.as_json(only: %w[name symbol])
    super(except: %w[created_at updated_at], methods: :display_name)
      .merge(currency_object: currency_as_json, shared: shared?, user: user.as_json(attributes_only: true))
  end

  def currency_object
    Money::Currency.find(currency)
  end

  def display_name
    name.presence || currency_object&.name
  end

  def shared?
    return false if user.blank?

    user != Current.user
  end

  private

  def validate_currency_stays_the_same
    return unless persisted? && currency_changed?

    errors.add(:currency, :cannot_change_after_creation)
  end
end
