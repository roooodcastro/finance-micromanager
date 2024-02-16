import { defineStore, storeToRefs } from 'pinia';
import _ from 'lodash';

import { statisticsCategorySummaries as categorySummariesApi } from '~/api/all.js';
import { fetchFromCache } from '~/utils/BrowserCacheUtils.js';
import useBrowserCacheStore from '~/stores/BrowserCacheStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';

export default defineStore('statistics_category_summary', {
  state: () => ({
    loading: false,
    categorySummaries: [],
  }),

  getters: {
    indexedSummaries: state => _.groupBy(state.categorySummaries, 'categoryId'),
    latestUpdatedAt: () => {
      const { latestUpdatedAtValues } = storeToRefs(useBrowserCacheStore());

      return latestUpdatedAtValues.value.categorySummary;
    },
  },

  actions: {
    fetchCollection(options) {
      this.loading = true;
      const dateRangeStore = useDateRangeStore();
      const { startDate, endDate } = storeToRefs(dateRangeStore);
      const defaultOptions = {
        startDate: startDate.value,
        endDate: endDate.value,
      };

      const path = categorySummariesApi.index.path({ query: Object.assign(defaultOptions, options) });

      return fetchFromCache(path, this.latestUpdatedAt)
        .then(data => this.categorySummaries = data.categorySummaries)
        .catch(() => {
          categorySummariesApi
            .index({ query: Object.assign(defaultOptions, options) })
            .then(data => this.categorySummaries = data.categorySummaries)
        })
        .finally(() => this.loading = false);
    },
  },
});
