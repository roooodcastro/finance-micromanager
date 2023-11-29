# frozen_string_literal: true

class CurrentDateRange < ActiveSupport::CurrentAttributes
  attribute :start_date, :end_date
end
