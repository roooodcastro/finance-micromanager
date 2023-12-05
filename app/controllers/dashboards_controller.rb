# frozen_string_literal: true

class DashboardsController < AbstractAuthenticatedController
  def show
    props = DashboardSerializer.new(Current.profile).as_json

    render inertia: 'dashboards/Show', props: camelize_props(props)
  end
end
