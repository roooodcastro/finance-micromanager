# frozen_string_literal: true

class ImportName < ApplicationRecord
  belongs_to :profile

  validates :import_name, :transaction_name, presence: true
  validates :import_name, uniqueness: { scope: :profile_id }

  def as_json
    super(only: %w[id import_name transaction_name profile_id updated_at])
  end
end
