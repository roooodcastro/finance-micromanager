# frozen_string_literal: true

module ActiveModelErrorMessages
  extend ActiveSupport::Concern

  def format_error_messages(resource)
    resource.errors.to_h do |error| # rubocop:disable Rails/DeprecatedActiveModelErrorsMethods
      [error.attribute, error.full_message]
    end
  end
end
