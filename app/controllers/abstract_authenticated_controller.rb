# frozen_string_literal: true

class AbstractAuthenticatedController < ApplicationController
  protect_from_forgery

  before_action :authenticate_user!

  inertia_share user: -> { camelize_props(current_user.as_json) }
  inertia_share currentProfile: -> { camelize_props(Current.profile.as_json) }
  inertia_share availableProfiles: -> { current_user.available_profiles.as_json.map(&method(:camelize_props)) }
end
