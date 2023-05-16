# frozen_string_literal: true

class DashboardsController < AbstractAuthenticatedController
  def show
    render inertia: 'dashboards/Show'
  end
end
