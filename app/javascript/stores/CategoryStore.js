import { defineStore, storeToRefs } from 'pinia'

import usePaginationStore from '~/stores/PaginationStore.js';
import { categories as categoriesApi } from "~/api";

export default defineStore('category', {
  state: () => ({
    categories: [],
    category: null,
  }),
  actions: {
    loadCategoriesFromProps(categories) {
      this.categories = categories;
    },
    fetchCategory(id, startDate, endDate) {
      const params = { start_date: startDate, end_date: endDate };
      categoriesApi
        .show({ id, query: params })
        .then(response => this.category = response.category);
    },
    fetchCategories(options = {}) {
      const paginationStore = usePaginationStore();
      const{ pagination } = storeToRefs(paginationStore);

      categoriesApi
        .index({ query: Object.assign(pagination.value, options) })
        .then((response) => {
          this.categories = response.categories;
          pagination.value = response.pagination;
        });
    },
    remove(id) {
      this.categories = this.categories.filter(category => category.id !== id);
    },
  },
});
