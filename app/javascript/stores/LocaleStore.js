import { defineStore } from 'pinia';
import { locales as localesApi } from '~/api/all.js';
import { BROWSER_CACHE_NAME } from '~/utils/Constants.js';

export default defineStore('locale', {
  state: () => ({
    locales: [],
  }),
  actions: {
    async fetchCollection() {
      const localesPath = localesApi.index.path();

      caches.open(BROWSER_CACHE_NAME).then((cache) => {
        return cache.match(localesPath).then((response) => {
          if (response) {
            return response.json().then(locales => this.locales = locales);
          }

          return fetch(localesPath).then((response) => {
            if (response.status === 200) {
              cache.put(localesPath, response.clone());
            }

            return response.json().then(locales => this.locales = locales);
          });
        });
      });
    },
  },
});
