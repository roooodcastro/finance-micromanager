import { defineStore } from 'pinia';

import I18n from '~/utils/I18n.js';
import { subcategories as subcategoriesApi } from '~/api';
import useNotificationStore from '~/stores/NotificationStore.js';

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
    disable(categoryId, id) {
      const notificationStore = useNotificationStore();

      subcategoriesApi.destroy({ categoryId, id }).then((response) => {
        notificationStore.notify(response.message, 'success');
        this.subcategories = response.subcategories;
      }).catch(() => {
        notificationStore.notify(I18n.t('views.layout.rails.generic_error'), 'danger');
      });
    },
  },
});
