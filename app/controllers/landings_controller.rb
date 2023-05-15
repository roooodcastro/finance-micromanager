# frozen_string_literal: true

class LandingsController < ApplicationController
  def show
    render inertia: 'landing/Show'
  end
end
