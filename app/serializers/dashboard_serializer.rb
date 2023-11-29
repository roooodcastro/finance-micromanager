# frozen_string_literal: true

class DashboardSerializer < ApplicationSerializer
  alias wallet record

  def as_json
    {
      categories:         wallet.categories.as_json,
      category_summaries: category_summaries.as_json
    }
  end

  private

  def category_summaries
    @category_summaries ||= Statistics::CategorySummaryQuery.run(
      wallet_id:  wallet.id,
      start_date: CurrentDateRange.start_date,
      end_date:   CurrentDateRange.end_date
    )
  end
end
