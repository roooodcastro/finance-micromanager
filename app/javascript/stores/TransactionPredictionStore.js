import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import { TRANSACTION_PREDICTION_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import I18n from '~/utils/I18n.js';

export default defineBaseApiStore('transactionPrediction', {
  resourceName: 'transactionPrediction',
  resourcesName: 'transactionPredictions',
  formId: TRANSACTION_PREDICTION_FORM_ID,
  api: transactionPredictionsApi,

  state: {
    transactionPredictions: [],
    transactionPrediction: null,
    currentConditionIndex: 0,
    currentAction: {},
    fetchParams: {},
  },

  actions: {
    destroy(id) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.transaction_predictions.confirmation.destroy') })
        .then(() => {
          transactionPredictionsApi
            .destroy({ id })
            .then((response) => {
              this.fetchCollection();
              notificationStore.notify(response.message, 'success');
              window.location.href = transactionPredictionsApi.index.path();
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
        .showConfirmationDialog({ message: I18n.t('views.transaction_predictions.confirmation.disable') })
        .then(() => {
          transactionPredictionsApi
            .disable({ id })
            .then((response) => {
              this.fetchCollection();
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
        .showConfirmationDialog({ message: I18n.t('views.transaction_predictions.confirmation.reenable') })
        .then(() => {
          transactionPredictionsApi
            .reenable({ id })
            .then((response) => {
              this.fetchCollection();
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
