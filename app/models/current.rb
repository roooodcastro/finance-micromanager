# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :account
  attribute :user
  attribute :locale
end
