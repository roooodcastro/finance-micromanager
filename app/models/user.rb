# frozen_string_literal: true

class User < ApplicationRecord
  devise :registerable, :trackable
  devise :confirmable, reconfirmable: true, confirm_within: 24.hours
  devise :database_authenticatable, send_email_changed_notification: true, send_password_change_notification: true
  devise :lockable, maximum_attempts: 3, lock_strategy: :failed_attempts, unlock_strategy: :email
  devise :recoverable, reset_password_within: 1.hour
  devise :rememberable, extend_remember_period: true

  attr_accessor :initial_currency

  belongs_to :default_profile, class_name: 'Profile', optional: true

  has_many :profiles, dependent: :restrict_with_exception
  has_many :profile_shares, dependent: :restrict_with_exception
  has_many :shared_profiles, -> { active }, class_name: 'Profile', through: :profile_shares, source: :profile
  has_many :profile_share_invites_sent, class_name: 'ProfileShareInvite', foreign_key: :profile_owner_id,
           dependent: :restrict_with_exception, inverse_of: :profile_owner
  has_many :profile_share_invites_received, class_name: 'ProfileShareInvite', inverse_of: :invitee,
           foreign_key: :invitee_email, primary_key: :email, dependent: :restrict_with_exception
  # rubocop:disable Rails/InverseOf
  has_many :active_profiles, -> { active }, class_name: 'Profile', dependent: :restrict_with_exception
  # rubocop:enable Rails/InverseOf

  validates :email, presence: true, uniqueness: true
  validates :default_profile, presence: true, unless: :new_record?

  validate :validate_email_in_allow_list

  after_save :set_default_profile!

  def find_available_profile(user_id)
    profile = profiles.find_by(id: user_id) || shared_profiles.find_by(id: user_id)
    raise ActiveRecord::RecordNotFound unless profile

    profile
  end

  def as_json(attributes_only: false, **)
    json = super(except: %w[created_at updated_at], methods: %i[full_name display_name])
    json.merge(default_profile: default_profile.as_json) unless attributes_only
    json
  end

  def display_name
    first_name.presence || email
  end

  def full_name
    return email unless first_name.presence || last_name.presence

    [first_name, last_name].compact.join(' ')
  end

  def available_profiles
    (active_profiles + shared_profiles).uniq
  end

  private

  def validate_email_in_allow_list
    allow_list = Rails.application.credentials.user_email_allowlist
    return if allow_list.empty?
    return if allow_list.include?(email)

    errors.add(:base, :email_not_valid)
  end

  def set_default_profile!
    return if default_profile

    profile = profiles.first || profiles.create(currency: initial_currency || :eur, status: :active)
    update!(default_profile: profile)
  end
end
