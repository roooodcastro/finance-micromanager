# frozen_string_literal: true

class DashboardSerializer < ApplicationSerializer
  alias profile record

  def as_json
    {
      categories:                 profile.categories.includes(:subcategories).order(:name).as_json,
      category_summaries:         category_summaries.as_json,
      in_progress_reconciliation: profile.reconciliations.in_progress.last.as_json || {}
    }
  end

  private

  def category_summaries
    @category_summaries ||= Statistics::CategorySummaryQuery.run(
      profile_id: profile.id,
      start_date: CurrentDateRange.start_date,
      end_date:   CurrentDateRange.end_date
    )
  end
end
