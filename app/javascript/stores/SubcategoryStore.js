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
      // Clone the subcategory so it doesn't affect the list before it's actually updated
      return { ...(state.subcategories.find(subcat => subcat.id === state.subcategoryIdForFormModal) ?? {}) };
    },
  },
  actions: {
    setSubcategoryIdForFormModal(id) {
      this.subcategoryIdForFormModal = id;
    },

    create(categoryId, subcategory) {
      const notificationStore = useNotificationStore();
      let responseResolve;
      const returnPromise = new Promise(resolve => responseResolve = resolve);

      subcategoriesApi.create({ params: { categoryId }, data: { subcategory } }).then((response) => {
        notificationStore.notify(response.message, 'success');
        this.subcategories = response.subcategories;
        responseResolve();
      }).catch((error) => {
        notificationStore.notify(error.body.message, 'danger');
      });

      return returnPromise;
    },

    update(categoryId, id, subcategory) {
      const notificationStore = useNotificationStore();
      let responseResolve;
      const returnPromise = new Promise(resolve => responseResolve = resolve);

      subcategoriesApi.update({ params: { categoryId, id }, data: { subcategory } }).then((response) => {
        notificationStore.notify(response.message, 'success');
        this.subcategories = response.subcategories;
        responseResolve();
      }).catch((error) => {
        notificationStore.notify(error.body.message, 'danger');
      });

      return returnPromise;
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
