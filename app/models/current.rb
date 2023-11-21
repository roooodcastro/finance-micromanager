# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :wallet
  attribute :user
  attribute :locale
end
