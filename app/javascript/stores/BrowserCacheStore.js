import { defineStore } from 'pinia';
import _ from 'lodash';
import dayjs from 'dayjs';

import { BROWSER_CACHE_NAME } from '~/utils/Constants.js';

const HEADER_NAME = 'Browser-Cache-Updated-At-Values';

export default defineStore('browserCacheStore', {
  state: () => ({
    updatedAtValues: {},
  }),
  getters: {

  },
  actions: {
    async loadFromResponse(response) {
      const headerValue = response.headers.get(HEADER_NAME);

      const updatedAtPairs = headerValue.split(',').map((updatedAtPair) => {
        const [resourceName, updatedAt] = updatedAtPair.split('=');
        return [resourceName, dayjs.unix(updatedAt)];
      });

      this.updatedAtValues = _.fromPairs(updatedAtPairs);
      // console.log(this.updatedAtValues.category);

      const clonedResponse = response.clone();

      caches.open(BROWSER_CACHE_NAME).then((cache) => {
        const url = new URL(response.url);
        const path = response.url.replace(url.origin, '');
        cache.put(path, clonedResponse);
      });
    },
  },
});
