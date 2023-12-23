import _ from 'lodash';
import { fixUuidObjectKeys } from '~/utils/StringUtils.js';
import { reconciliations as reconciliationsApi } from '~/api/all.js';
import { RECONCILIATION_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

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
  },
});
