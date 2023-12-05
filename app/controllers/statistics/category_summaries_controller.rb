# frozen_string_literal: true

module Statistics
  class CategorySummariesController < AbstractAuthenticatedController
    def index
      category_summaries = Statistics::CategorySummaryQuery.run(
        profile_id: Current.profile.id,
        start_date: CurrentDateRange.start_date,
        end_date:   CurrentDateRange.end_date
      ).as_json

      render json: camelize_props(category_summaries:)
    end
  end
end
