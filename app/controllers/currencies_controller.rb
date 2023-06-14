# frozen_string_literal: true

class CurrenciesController < AbstractAuthenticatedController
  def index
    render json: Money::Currency.all.as_json(only: %w[id iso_code name symbol])
  end
end
