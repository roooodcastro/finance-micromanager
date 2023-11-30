import { defineStore, storeToRefs } from 'pinia'

import usePaginationStore from '~/stores/PaginationStore.js';
import { categories as categoriesApi } from "~/api";

export default defineStore('category', {
  state: () => ({
    categories: [],
    category: null,
  }),
  actions: {
    fetchCategory(id, startDate, endDate) {
      const params = { start_date: startDate, end_date: endDate };
      categoriesApi
        .show({ id, query: params })
        .then(response => this.category = response.category);
    },
    fetchCategories() {
      const paginationStore = usePaginationStore();
      const{ pagination } = storeToRefs(paginationStore);
      const params = pagination.value;

      categoriesApi
        .index({ query: params })
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
