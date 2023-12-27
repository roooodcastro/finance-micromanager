import _ from 'lodash';

import { reconciliations as reconciliationsApi } from '~/api/all.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import { fixUuidObjectKeys } from '~/utils/StringUtils.js';
import { RECONCILIATION_FORM_ID } from '~/utils/Constants.js';
import I18n from '~/utils/I18n.js';

export default defineBaseApiStore('reconciliation', {
  resourceName: 'reconciliation',
  resourcesName: 'reconciliations',
  formId: RECONCILIATION_FORM_ID,
  api: reconciliationsApi,

  state: {
    reconciliations: [],
    reconciliation: null,
    walletBalances: [],
    idForFormModal: null,
    fetchParams: {},
  },

  getters: {
    realBalancesSum: (state) => {
      return state.reconciliation.reconciliationsWallets.reduce((sum, reconciliationWallet) => {
        return sum + reconciliationWallet.balanceAmount;
      }, 0);
    },
    walletBalancesSum: state => _.sum(_.values(state.walletBalances)),
  },

  actions: {
    fetchSingle(id = null) {
      return reconciliationsApi.show({ id: id ?? this.reconciliation.id }).then((response) => {
        this.reconciliation = response.reconciliation;
        this.walletBalances = fixUuidObjectKeys(response.walletBalances);
      });
    },

    finish(id) {
      const notificationStore = useNotificationStore();

      reconciliationsApi
        .finish({ id })
        .then((response) => {
          this.fetch();
          notificationStore.notify(response.message, 'success');
        })
        .catch((error) => {
          const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
          notificationStore.notify(errorMessage, 'danger');
        });
    },

    cancel(id) {
      const notificationStore = useNotificationStore();

      reconciliationsApi
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
