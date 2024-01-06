import { defineStore } from 'pinia'
import { locales as localesApi } from '~/api/all.js';

export default defineStore('locale', {
  state: () => ({
    locales: [],
  }),
  actions: {
    fetch() {
      localesApi.index().then((response) => {
        this.locales = response;
      });
    },
  },
});
