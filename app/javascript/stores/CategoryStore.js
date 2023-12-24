import { defineStore } from 'pinia';

import { categories as categoriesApi } from '~/api/all.js';

export default defineStore('category', {
  state: () => ({
    categories: [],
    category: null,
  }),
  getters: {
    categoriesForSelect: (state) => {
      return state.categories.reduce((result, category) => {
        result.push({ label: category.name, value: category.id })
        category.subcategories.forEach((subcategory) => {
          result.push({ label: subcategory.displayName, value: `${category.id}|${subcategory.id}`});
        });
        return result;
      }, []);
    },
  },
  actions: {
    fetchCategory(id, startDate, endDate) {
      const params = { start_date: startDate, end_date: endDate };
      categoriesApi
        .show({ id, query: params })
        .then(response => this.category = response.category);
    },
    fetch(options = {}) {
      categoriesApi
        .index({ query: options })
        .then(response => this.categories = response.categories);
    },
    remove(id) {
      this.categories = this.categories.filter(category => category.id !== id);
    },
  },
});
