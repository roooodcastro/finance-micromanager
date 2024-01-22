import { defineStore } from 'pinia';
import _ from 'lodash';
import dayjs from 'dayjs';

import {
  BROWSER_CACHE_NAME,
  LATEST_UPDATED_AT_VALUES_HEADER_NAME,
} from '~/utils/Constants.js';

const loadLatestUpdatedAtValues = (store, rawString) => {
  const updatedAtPairs = rawString.split(',').map((updatedAtPair) => {
    const [resourceName, updatedAt] = updatedAtPair.split('=');
    return [resourceName.trim(), dayjs.unix(updatedAt)];
  });

  store.latestUpdatedAtValues = _.fromPairs(updatedAtPairs);
};

export default defineStore('browserCacheStore', {
  state: () => ({
    latestUpdatedAtValues: {},
  }),
  getters: {

  },
  actions: {
    loadFromPageLoad() {
      const rawValue = document.querySelector('meta[name="browser-cache-updated-at-values"]')?.content;
      loadLatestUpdatedAtValues(this, rawValue);
    },
    loadFromResponse(response) {
      const headerValue = response.headers.get(LATEST_UPDATED_AT_VALUES_HEADER_NAME);
      loadLatestUpdatedAtValues(this, headerValue);

      const clonedResponse = response.clone();

      caches.open(BROWSER_CACHE_NAME).then((cache) => {
        const url = new URL(response.url);
        const path = response.url.replace(url.origin, '');
        cache.put(path, clonedResponse);
      });
    },
  },
});
