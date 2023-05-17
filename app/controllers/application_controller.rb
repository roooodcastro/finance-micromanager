# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetCurrentAttributes
  include ActiveModelErrorMessages

  before_action :set_current_attributes

  inertia_share flashMessages: -> { flash.to_h }
end
