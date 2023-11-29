import { defineStore } from 'pinia'
import moment from 'moment';

import { statisticsCategorySummaries as categorySummariesApi } from '~/api';

export default defineStore('statistics_category_summary', {
  state: () => ({
    categorySummaries: [],
  }),

  getters: {
    indexedSummaries: (state) => {
      return state.categorySummaries.reduce((result, summary) => {
        result[summary.categoryId] = summary;
        return result;
      }, {});
    },
  },

  actions: {
    fetch(options) {
      const defaultOptions = {
        startDate: moment().startOf('month'),
        endDate: moment(),
      };

      categorySummariesApi
        .index({ query: Object.assign(defaultOptions, options) })
        .then(response => this.categorySummaries = response.categorySummaries);
    },
  },
});
