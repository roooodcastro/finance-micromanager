# frozen_string_literal: true

class AbstractAuthenticatedController < ApplicationController
  before_action :authenticate_user!

  inertia_share user: -> { current_user }
end
