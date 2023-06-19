# frozen_string_literal: true

class ProfilesController < AbstractAuthenticatedController
  def show
    render inertia: 'profiles/Show', props: { user: camelize_props(current_user.as_json) }
  end
end
