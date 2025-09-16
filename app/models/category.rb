# frozen_string_literal: true

class Category < ApplicationRecord
  include CacheLatestUpdatedAt
  include Disableable

  HEX_COLOR_REGEX                = /\A#[[0-9][a-f]]{6}\z/i
  TEMPORARY_NAME                 = 'Temporary'
  RECONCILIATION_NAME            = 'reconciliations.category_name'
  SYSTEM_CATEGORY_COLOR          = '#808080'
  USER_SELECTABLE_CATEGORY_TYPES = %w[user income].freeze

  belongs_to :profile

  has_one :budget, as: :owner, dependent: :restrict_with_exception

  has_many :transactions, dependent: :restrict_with_exception
  has_many :subcategories, dependent: :restrict_with_exception
  has_many :budget_instances, as: :owner, dependent: :restrict_with_exception

  # rubocop:disable Rails/InverseOf
  has_many :active_subcategories, -> { active }, class_name: 'Subcategory', dependent: :restrict_with_exception
  # rubocop:enable Rails/InverseOf

  enum :category_type, { user: 'user', system: 'system', income: 'income' }, default: 'user'

  validates :name, presence: true
  validates :color, format: { with: HEX_COLOR_REGEX }

  validate :validate_system_category

  def self.reconciliation_category_for(profile)
    find_or_create_by!(
      profile:       profile,
      name:          RECONCILIATION_NAME,
      color:         SYSTEM_CATEGORY_COLOR,
      category_type: :system
    )
  end

  def self.temporary_category_for(profile)
    find_by!(profile: profile, name: TEMPORARY_NAME, category_type: :system)
  rescue ActiveRecord::RecordNotFound
    create!(profile: profile, name: TEMPORARY_NAME, color: SYSTEM_CATEGORY_COLOR, category_type: :system)
  end

  # Splits category ID that's composed with a subcategory ID, like for example "1234|5678"
  def self.split_compose_category_id(compose_category_id)
    return [nil, nil] if compose_category_id.blank?

    category_id, subcategory_id = compose_category_id.split('|')
    [category_id, subcategory_id]
  end

  def as_json(include_subcategories: true)
    json = super.merge(
      'system' => system?,
      'name'   => display_name
    )

    json = json.merge(subcategories: active_subcategories.as_json) if include_subcategories
    json
  end

  def display_name
    system? ? I18n.t(name) : name
  end

  def validate_system_category
    return if !persisted? || !system?

    errors.add(:base, :cannot_edit_system_category)
  end

  def disable!
    update!(favourite: false)
    super
  end
end
