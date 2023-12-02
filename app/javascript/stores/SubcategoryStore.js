import { defineStore } from 'pinia';

import I18n from '~/utils/I18n.js';
import { subcategories as subcategoriesApi } from '~/api';
import useNotificationStore from '~/stores/NotificationStore.js';

export default defineStore('subcategory', {
  state: () => ({
    categoryId: null,
    subcategories: [],
    subcategoryIdForFormModal: null,
    showDisabled: false,
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
    setShowDisabled(showDisabled) {
      if (this.showDisabled !== showDisabled) {
        this.showDisabled = showDisabled;

        return this.fetch();
      } else {
        return Promise.resolve();
      }
    },

    fetch() {
      subcategoriesApi
        .index({ categoryId: this.categoryId, query: { showDisabled: this.showDisabled }})
        .then((response) => this.subcategories = response.subcategories);
    },

    create(categoryId, subcategory) {
      const notificationStore = useNotificationStore();
      let responseResolve;
      const returnPromise = new Promise(resolve => responseResolve = resolve);

      subcategoriesApi
        .create({ params: { categoryId }, data: { subcategory }, query: { showDisabled: this.showDisabled } })
        .then((response) => {
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

      subcategoriesApi
        .update({
          params: { categoryId, id },
          data: { subcategory },
          query: { showDisabled: this.showDisabled }
        })
        .then((response) => {
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

      subcategoriesApi
        .destroy({ categoryId, id, query: { showDisabled: this.showDisabled } })
        .then((response) => {
          notificationStore.notify(response.message, 'success');
          this.subcategories = response.subcategories;
        }).catch(() => {
          notificationStore.notify(I18n.t('views.layout.rails.generic_error'), 'danger');
        });
    },

    reenable(id) {
      const notificationStore = useNotificationStore();

      subcategoriesApi
        .reenable({ categoryId: this.categoryId, id, query: { showDisabled: this.showDisabled } })
        .then((response) => {
          notificationStore.notify(response.message, 'success');
          this.subcategories = response.subcategories;
        }).catch(() => {
          notificationStore.notify(I18n.t('views.layout.rails.generic_error'), 'danger');
        });
    }
  },
});
