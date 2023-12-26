import { defineBaseApiStore } from '~/stores/BaseApiStore.js';
import { storeToRefs } from 'pinia';
import _ from 'lodash';

import I18n from '~/utils/I18n.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { transactions as transactionsApi } from '~/api/all.js';

import {
  DEBIT_TRANSACTION,
  CREDIT_TRANSACTION,
  TRANSACTION_FORM_ID,
  MASS_EDIT_TRANSACTION_FORM_ID,
} from '~/utils/Constants.js';

export default defineBaseApiStore('transaction', {
  resourceName: 'transaction',
  resourcesName: 'transactions',
  formId: TRANSACTION_FORM_ID,
  api: transactionsApi,

  state: {
    transactions: [],
    idForFormModal: null,
    massEditMode: false,
    massEditTransactionIds: [],
    defaultTransactionDate: new Date().toISOString().split('T')[0],
    fetchParams: {
      daysToShow: 30,
      excludeDebits: false,
      excludeCredits: false,
      updateDateRange: true,
    },
  },
  getters: {
    daysToShow: state => state.fetchParams.daysToShow,
    excludeDebits: state => state.fetchParams.excludeDebits,
    excludeCredits: state => state.fetchParams.excludeCredits,
    groupedTransactions: state => _.groupBy(state.transactions, 'transactionDate'),
    massEditTransactionIdsCount: state => Object.keys(state.massEditTransactionIds).length,
  },
  actions: {
    fetch(options = {}) {
      const paginationStore = usePaginationStore();
      const { pagination } = storeToRefs(paginationStore);
      const keepTransactions = options.keepTransactions;
      delete options.keepTransactions;

      return transactionsApi
        .index({ query: Object.assign(this.fetchParams, pagination.value) })
        .then((response) => {
          keepTransactions
            ? this.transactions.push(...response.transactions)
            : this.transactions = response.transactions;

          pagination.value = response.pagination;
        });
    },

    enterMassEditMode() {
      this.massEditMode = true;
      this.massEditTransactionIds = {};
    },

    cancelMassEditMode() {
      this.massEditMode = false;
      this.massEditTransactionIds = {};
    },

    submitMassEdit() {
      if (this.massEditTransactionIdsCount > 0) {
        const modalStore = useModalStore();
        modalStore.show(MASS_EDIT_TRANSACTION_FORM_ID);
      }
    },

    deselectAllMassEditMode() {
      this.massEditTransactionIds = {};
    },

    toggleMassEditTransactionId(transactionId) {
      if (this.massEditTransactionIds[transactionId]) {
        delete this.massEditTransactionIds[transactionId];
      } else {
        this.massEditTransactionIds[transactionId] = true;
      }
    },

    massUpdate(transaction) {
      const notificationStore = useNotificationStore();
      let responseResolve;
      const returnPromise = new Promise(resolve => responseResolve = resolve);
      const transactionIds = Object.keys(this.massEditTransactionIds);

      transactionsApi
        .updateAll({ data: { transaction, transactionIds } })
        .then((response) => {
          this.fetch();
          document.querySelector(`#${MASS_EDIT_TRANSACTION_FORM_ID}`).reset();
          notificationStore.notify(response.message, 'success');
          this.cancelMassEditMode();
          responseResolve();
        })
        .catch((error) => {
          const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
          notificationStore.notify(errorMessage, 'danger');
        });

      return returnPromise;
    },

    remove(id) {
      this.transactions = this.transactions.filter(transaction => transaction.id !== id);
    },

    setTransactionType(newType) {
      this.fetchParams.excludeCredits = newType === DEBIT_TRANSACTION;
      this.fetchParams.excludeDebits = newType === CREDIT_TRANSACTION;
    },
  }
});
