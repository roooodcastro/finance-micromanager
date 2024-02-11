import { storeToRefs } from 'pinia';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

import I18n from '~/utils/I18n.js';
import { CATEGORY_FORM_ID } from '~/utils/Constants.js';
import { categories as categoriesApi } from '~/api/all.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useModalStore from '~/stores/ModalStore.js';

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
    showDisabled: state => state.fetchParams.showDisabled,
    showSystem: state => state.fetchParams.showSystem,
  },

  actions: {
    categoryNameFor(rawCategoryId) {
      const [categoryId, subcategoryId] = rawCategoryId.split('|');
      const category = this.categories.find(category => category.id === categoryId);

      if (category && subcategoryId) {
        const subcategory = category.subcategories.find(subcategory => subcategory.id === subcategoryId);
        return subcategory?.displayName;
      } else {
        return category?.name;
      }
    },
    fetchSingle(id) {
      this.loading = true;
      const dateRangeStore = useDateRangeStore();
      const { startDate, endDate } = storeToRefs(dateRangeStore);
      const params = Object.assign({ startDate: startDate.value, endDate: endDate.value }, this.fetchParams);

      categoriesApi
        .show({ id, query: params })
        .then(response => this.category = response.category)
        .finally(() => this.loading = false);
    },

    disable(id, fetchOptions = {}) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.categories.confirmation.disable') })
        .then(() => {
          categoriesApi
            .destroy({ id })
            .then((response) => {
              this.fetch(id, fetchOptions);
              notificationStore.notify(response.message, 'success');
            })
            .catch((error) => {
              const errorMessage = error?.body?.message ?? I18n.t('views.layout.rails.generic_error');
              notificationStore.notify(errorMessage, 'danger');
            });
        });
    },

    reenable(id, fetchOptions = {}) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.categories.confirmation.reenable') })
        .then(() => {
          categoriesApi
            .reenable({ id })
            .then((response) => {
              this.fetch(id, fetchOptions);
              notificationStore.notify(response.message, 'success');
            })
            .catch((error) => {
              const errorMessage = error?.body?.message ?? I18n.t('views.layout.rails.generic_error');
              notificationStore.notify(errorMessage, 'danger');
            });
        });
    },
  },
});
