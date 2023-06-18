# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetCurrentAttributes
  include ActiveModelErrorMessages
  include CamelizeableProps
  include Localizeable

  add_flash_types :success, :warning, :danger

  inertia_share flashMessages: -> { flash.to_h }
end
