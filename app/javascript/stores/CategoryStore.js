import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

import I18n from '~/utils/I18n.js';
import { CATEGORY_FORM_ID } from '~/utils/Constants.js';
import { categories as categoriesApi } from '~/api/all.js';
import useNotificationStore from '~/stores/NotificationStore.js';

export default defineBaseApiStore('category', {
  resourceName: 'category',
  resourcesName: 'categories',
  formId: CATEGORY_FORM_ID,
  api: categoriesApi,

  state: {
    categories: [],
    category: null,
  },

  getters: {
    categoriesForSelect: (state) => {
      return (includeSystem = false) => {
        return state.categories.reduce((result, category) => {
          if (!includeSystem && category.system) {
            return result;
          }

          result.push({ label: category.name, value: category.id })
          category.subcategories.forEach((subcategory) => {
            result.push({ label: subcategory.displayName, value: `${category.id}|${subcategory.id}`});
          });
          return result;
        }, []);
      };
    },
  },

  actions: {
    fetchCategory(id, startDate, endDate) {
      const params = { start_date: startDate, end_date: endDate };
      categoriesApi
        .show({ id, query: params })
        .then(response => this.category = response.category);
    },

    disable(id) {
      const notificationStore = useNotificationStore();

      categoriesApi
        .destroy({ id })
        .then((response) => {
          this.fetch();
          notificationStore.notify(response.message, 'success');
        })
        .catch((error) => {
          const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
          notificationStore.notify(errorMessage, 'danger');
        });
    },
  },
});
