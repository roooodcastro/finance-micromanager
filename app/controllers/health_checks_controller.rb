# frozen_string_literal: true

class HealthChecksController < ApplicationController
  skip_before_action :set_current_attributes

  newrelic_ignore

  def show
    render plain: 'OK'
  end
end
