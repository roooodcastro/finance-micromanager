# frozen_string_literal: true

class Account < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :user

  has_many :transactions, dependent: :restrict_with_exception
  has_many :categories, dependent: :restrict_with_exception
  has_many :imports, dependent: :restrict_with_exception
  has_many :account_users, dependent: :restrict_with_exception

  has_many :shared_users, class_name: 'User', through: :account_users, source: :user

  scope :shared_with, ->(user) { left_joins(:account_users).where(account_users: { user: }) }

  enum status: { active: 'active', disabled: 'disabled' }

  validates :status, presence: true
  validates :currency, presence: true, inclusion: { in: Money::Currency.map(&:id).map(&:to_s) }
  validates :name, length: { maximum: 30 }, allow_blank: true

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
end
