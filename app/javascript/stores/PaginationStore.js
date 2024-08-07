import { defineStore } from 'pinia';

export default defineStore('pagination', {
  state: () => ({
    pagination: {},
  }),

  actions: {
    setPaginationOptions(options) {
      this.pagination = Object.assign(this.pagination, options);
    },
    setPerPage(perPage) {
      this.pagination.limit = perPage;
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
