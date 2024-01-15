import { storeToRefs } from 'pinia';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

import I18n from '~/utils/I18n.js';
import { CATEGORY_FORM_ID } from '~/utils/Constants.js';
import { categories as categoriesApi } from '~/api/all.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';

export default defineBaseApiStore('category', {
  resourceName: 'category',
  resourcesName: 'categories',
  formId: CATEGORY_FORM_ID,
  api: categoriesApi,

  state: {
    categories: [],
    category: null,
    fetchParams: {
      updateDateRange: true,
    },
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
    fetchSingle(id) {
      const dateRangeStore = useDateRangeStore();
      const { startDate, endDate } = storeToRefs(dateRangeStore);
      const params = Object.assign({ startDate: startDate.value, endDate: endDate.value }, this.fetchParams);

      categoriesApi
        .show({ id, query: params })
        .then(response => this.category = response.category);
    },

    disable(id) {
      const notificationStore = useNotificationStore();

      categoriesApi
        .destroy({ id })
        .then((response) => {
          this.fetchCollection();
          notificationStore.notify(response.message, 'success');
        })
        .catch((error) => {
          const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
          notificationStore.notify(errorMessage, 'danger');
        });
    },
  },
});
