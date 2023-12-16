import { defineStore } from 'pinia'
import _ from 'lodash';
import dayjs from 'dayjs';

import { statisticsCategorySummaries as categorySummariesApi } from '~/api/all.js';

export default defineStore('statistics_category_summary', {
  state: () => ({
    categorySummaries: [],
  }),

  getters: {
    indexedSummaries: (state) => {
      return _.keyBy(state.categorySummaries, 'categoryId');
    },
  },

  actions: {
    fetch(options) {
      const defaultOptions = {
        startDate: dayjs().startOf('month'),
        endDate: dayjs(),
      };

      categorySummariesApi
        .index({ query: Object.assign(defaultOptions, options) })
        .then(response => this.categorySummaries = response.categorySummaries);
    },
  },
});
