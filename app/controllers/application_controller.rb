# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetCurrentAttributes

  before_action :set_current_attributes
end
