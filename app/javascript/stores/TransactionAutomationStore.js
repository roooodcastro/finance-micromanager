import { transactionAutomations as transactionAutomationsApi } from '~/api/all.js';
import { TRANSACTION_AUTOMATION_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import I18n from '~/utils/I18n.js';

export default defineBaseApiStore('transactionAutomation', {
  resourceName: 'transactionAutomation',
  resourcesName: 'transactionAutomations',
  formId: TRANSACTION_AUTOMATION_FORM_ID,
  api: transactionAutomationsApi,

  state: {
    transactionAutomations: [],
    transactionAutomation: null,
    fetchParams: {},
  },

  actions: {
    fetchSingle(id) {
      transactionAutomationsApi
        .show({ id })
        .then(response => this.transactionAutomation = response.transactionAutomation);
    },
    destroy(id) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.transaction_automations.confirmation.destroy') })
        .then(() => {
          transactionAutomationsApi
            .destroy({ id })
            .then((response) => {
              this.fetch();
              notificationStore.notify(response.message, 'success');
              window.location.href = transactionAutomationsApi.index.path();
            })
            .catch((error) => {
              const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
              notificationStore.notify(errorMessage, 'danger');
            });
        })
        .catch(() => {});
    },
    disable(id) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.transaction_automations.confirmation.disable') })
        .then(() => {
          transactionAutomationsApi
            .disable({ id })
            .then((response) => {
              this.fetch();
              this.fetchSingle(id);
              notificationStore.notify(response.message, 'success');
            })
            .catch((error) => {
              const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
              notificationStore.notify(errorMessage, 'danger');
            });
        });
    },
    reenable(id) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.transaction_automations.confirmation.reenable') })
        .then(() => {
          transactionAutomationsApi
            .reenable({ id })
            .then((response) => {
              this.fetch();
              this.fetchSingle(id);
              notificationStore.notify(response.message, 'success');
            })
            .catch((error) => {
              const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
              notificationStore.notify(errorMessage, 'danger');
            });
        });
    },
  },
});
