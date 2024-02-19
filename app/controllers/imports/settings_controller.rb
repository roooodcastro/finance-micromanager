# frozen_string_literal: true

module Imports
  class SettingsController < AbstractAuthenticatedController
    def show
      render inertia: 'imports/settings/Show'
    end
  end
end
