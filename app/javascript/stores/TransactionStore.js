import { defineBaseApiStore } from '~/stores/BaseApiStore.js';
import { storeToRefs } from 'pinia';
import _ from 'lodash';

import I18n from '~/utils/I18n.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { transactions as transactionsApi } from '~/api/all.js';
import { isMediaBreakpointDown } from '~/utils/ResponsivenessUtils.js';

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
    statistics: {},
    idForFormModal: null,
    massEditMode: false,
    massEditTransactionIds: [],
    defaultTransactionDate: new Date().toISOString().split('T')[0],
    fetchParams: {
      daysToShow: 30,
      excludeDebits: false,
      excludeCredits: false,
      updateDateRange: true,
      includeStatistics: false,
      searchString: '',
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
    fetchCollection(options = {}) {
      this.loading = true;
      const paginationStore = usePaginationStore();
      const dateRangeStore = useDateRangeStore();
      const { pagination } = storeToRefs(paginationStore);
      const { startDate, endDate } = storeToRefs(dateRangeStore);
      const keepTransactions = options.keepTransactions;
      delete options.keepTransactions;

      /*
        This means that it's a mobile layout (with infinite scrolling), and this is nota fetch from
        infinite scrolling, so we must reset the page back to 1 otherwise we'll end up with missing transactions.
       */
      if (!keepTransactions && isMediaBreakpointDown('md')) {
        pagination.value.page = 1;
      }

      return transactionsApi
        .index({ query: Object.assign({ startDate: startDate.value, endDate: endDate.value }, this.fetchParams, pagination.value) })
        .then((response) => {
          keepTransactions
            ? this.transactions.push(...response.transactions)
            : this.transactions = response.transactions;

          if (this.fetchParams.includeStatistics) {
            this.statistics = response.statistics;
          }

          pagination.value = response.pagination;
        })
        .finally(() => {
          this.loading = false;
          this.initialFetchDone = true;
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

    selectAllMassEditMode() {
      const newTransactionIds = this.transactions.reduce((result, transaction) => {
        result[transaction.id] = true;
        return result;
      }, {});
      this.massEditTransactionIds = Object.assign(this.massEditTransactionIds, newTransactionIds);
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
      let responseReject;
      const returnPromise = new Promise((resolve, reject) => {
        responseResolve = resolve;
        responseReject = reject;
      });

      const transactionIds = Object.keys(this.massEditTransactionIds);

      transactionsApi
        .updateAll({ data: { transaction, transactionIds } })
        .then((response) => {
          this.fetchCollection();
          document.querySelector(`#${MASS_EDIT_TRANSACTION_FORM_ID}`).reset();
          notificationStore.notify(response.message, 'success');
          this.cancelMassEditMode();
          responseResolve();
        })
        .catch((error) => {
          const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
          notificationStore.notify(errorMessage, 'danger');
          responseReject(error);
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
