# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetCurrentAttributes

  use_inertia_instance_props

  before_action :set_current_attributes
end
