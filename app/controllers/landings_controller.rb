# frozen_string_literal: true

class LandingsController < AbstractPublicController
  def show
    render inertia: 'landings/Show'
  end
end
