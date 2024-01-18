import { defineStore } from 'pinia';

import { reconciliationsWallets as reconciliationsWalletsApi } from '~/api/all.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import I18n from '~/utils/I18n.js';

export default defineStore('reconciliationWallet', {
  state: () => ({
    reconciliationId: null,
  }),

  actions: {
    setReconciliationId(reconciliationId) {
      this.reconciliationId = reconciliationId;
    },

    create(id, record) {
      const notificationStore = useNotificationStore();
      const reconciliationStore = useReconciliationStore();

      let responseResolve;
      let responseReject;
      const returnPromise = new Promise((resolve, reject) => {
        responseResolve = resolve;
        responseReject = reject;
      });

      const data = { id, reconciliationWallet: record };

      reconciliationsWalletsApi
        .create({ params: { reconciliationId: this.reconciliationId }, data })
        .then(() => reconciliationStore.fetchSingle(this.reconciliationId).then(responseResolve))
        .catch((error) => {
          const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
          notificationStore.notify(errorMessage, 'danger');
          responseReject(error);
        });

      return returnPromise;
    },
  },
});
