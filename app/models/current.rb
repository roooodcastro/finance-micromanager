# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :profile
  attribute :user
  attribute :locale
end
