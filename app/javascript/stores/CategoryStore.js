import { defineStore } from 'pinia'
import { categories as categoriesApi } from "~/api";

export default defineStore('category', {
  state: () => ({
    categories: [],
    pagination: {},
  }),
  actions: {
    fetchCategories() {
      const params = { page: this.pagination.page };
      categoriesApi
        .index({ query: params })
        .then((response) => {
          this.categories = response.categories;
          this.pagination = response.pagination;
        });
    },
    remove(id) {
      this.categories = this.categories.filter(category => category.id !== id);
    },
    changePage(page) {
      this.pagination.page = page;
      this.fetchCategories();
    },
  },
});
