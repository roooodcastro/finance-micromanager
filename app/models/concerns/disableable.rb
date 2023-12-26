# frozen_string_literal: true

module Disableable
  extend ActiveSupport::Concern

  included do
    belongs_to :disabled_by, class_name: 'User', optional: true

    scope :active, -> { where(disabled_at: nil) }
    scope :disabled, -> { where.not(disabled_at: nil) }
  end

  def disable!
    return false unless can_disable?

    update!(disabled_at: Time.current, disabled_by: Current.user)
  end

  def enable!
    return false unless can_enable?

    update!(disabled_at: nil, disabled_by: nil)
  end

  private

  def can_disable?
    true
  end

  def can_enable?
    true
  end
end
