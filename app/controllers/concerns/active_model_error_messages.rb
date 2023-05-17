# frozen_string_literal: true

module ActiveModelErrorMessages
  extend ActiveSupport::Concern

  def format_error_messages(resource)
    resource.errors.each_with_object({}) do |error, result|
      result[error.attribute] = error.full_message
    end
  end
end
