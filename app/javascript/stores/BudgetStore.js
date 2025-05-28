import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

import I18n from '~/utils/I18n.js';
import { BUDGET_FORM_ID } from '~/utils/Constants.js';
import { budgets as budgetsApi } from '~/api/all.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';

export default defineBaseApiStore('budget', {
  resourceName: 'budget',
  resourcesName: 'budgets',
  formId: BUDGET_FORM_ID,
  api: budgetsApi,

  state: {
    budgets: [],
    budget: null,
    fetchParams: {},
  },

  actions: {
    fetchSingle(id) {
      this.loading = true;
      budgetsApi
        .show({ id, query: this.fetchParams })
        .then(response => this.budget = response.budget)
        .finally(() => this.loading = false);
    },

    disable(id, fetchOptions = {}) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.budgets.confirmation.disable') })
        .then(() => {
          budgetsApi
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
        .showConfirmationDialog({ message: I18n.t('views.budgets.confirmation.reenable') })
        .then(() => {
          budgetsApi
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
