# frozen_string_literal: true

class DashboardsController < AbstractAuthenticatedController
  def show
    render inertia: 'dashboard/Show'
  end
end
