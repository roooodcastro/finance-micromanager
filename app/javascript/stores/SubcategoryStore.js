import { defineStore } from 'pinia';

export default defineStore('subcategory', {
  state: () => ({
    subcategories: [],
    subcategoryIdForFormModal: null,
  }),
  getters: {
    subcategoryForFormModal: (state) => {
      return state.subcategories.find(subcat => subcat.id === state.subcategoryIdForFormModal) ?? {};
    },
  },
  actions: {
    setSubcategoryIdForFormModal(id) {
      this.subcategoryIdForFormModal = id;
    },
  },
});
