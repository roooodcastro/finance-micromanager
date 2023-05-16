# frozen_string_literal: true

class LandingsController < ApplicationController
  def show
    render inertia: 'landings/Show'
  end
end
