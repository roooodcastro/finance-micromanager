# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetCurrentAttributes
  include ActiveModelErrorMessages
  include CamelizeableProps
  include Localizeable
  include StorePaginationOptions
  include BrowserCacheHeader

  add_flash_types :success, :warning, :danger, :info

  inertia_share notifications: -> { flash.to_h }
end
