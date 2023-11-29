# frozen_string_literal: true

class DashboardsController < AbstractAuthenticatedController
  def show
    props = DashboardSerializer.new(Current.wallet).as_json

    render inertia: 'dashboards/Show', props: camelize_props(props)
  end
end
