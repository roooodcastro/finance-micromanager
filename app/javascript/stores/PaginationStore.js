import { defineStore } from 'pinia';

export default defineStore('pagination', {
  state: () => ({
    pagination: {},
  }),

  actions: {
    setPerPage(perPage) {
      this.pagination.items = perPage;
    },
    setPage(page) {
      this.pagination.page = page;
    },
    incrementPage() {
      if (this.pagination.pages > this.pagination.page) {
        this.pagination.page += 1;
        return true;
      } else {
        return false;
      }
    }
  },
});
