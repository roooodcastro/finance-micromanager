import { defineStore, storeToRefs } from 'pinia';
import _ from 'lodash';

import usePaginationStore from '~/stores/PaginationStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import { transactions as transactionsApi } from '~/api';
import { DEBIT_TRANSACTION, CREDIT_TRANSACTION } from '~/utils/Constants.js';

export default defineStore('transaction', {
  state: () => ({
    transactions: [],
    transactionIdForFormModal: null,
    daysToShow: 30,
    excludeDebits: false,
    excludeCredits: false,
  }),
  getters: {
    transactionForFormModal: (state) => {
      // Clone the transaction so it doesn't affect the list before it's actually updated
      return { ...(state.transactions.find(transaction => transaction.id === state.transactionIdForFormModal) ?? {}) };
    },
    groupedTransactions: state => {
      return _.groupBy(state.transactions, 'transactionDate');
    }
  },
  actions: {
    fetch(options = {}) {
      const paginationStore = usePaginationStore();
      const { pagination } = storeToRefs(paginationStore);
      const keepTransactions = options.keepTransactions;
      delete options.keepTransactions;

      const defaultOptions = {
        daysToShow: this.daysToShow,
        excludeDebits: this.excludeDebits,
        excludeCredits: this.excludeCredits,
        ...(pagination.value),
      };
      return transactionsApi
        .index({ query: Object.assign(defaultOptions, options) })
        .then((response) => {
          keepTransactions
            ? this.transactions.push(...response.transactions)
            : this.transactions = response.transactions;

          pagination.value = response.pagination;
        });
    },

    create(transaction) {
      let responseResolve;
      const notificationStore = useNotificationStore();
      const returnPromise = new Promise(resolve => responseResolve = resolve);

      transactionsApi
        .create({ data: { transaction } })
        .then((response) => {
          notificationStore.notify(response.message, 'success');
          this.fetch().then(() => responseResolve());
        }).catch((error) => {
        notificationStore.notify(error.body.message, 'danger');
      });

      return returnPromise;
    },

    update(id, transaction) {
      const notificationStore = useNotificationStore();
      let responseResolve;
      const returnPromise = new Promise(resolve => responseResolve = resolve);

      transactionsApi
        .update({ params: { id } , data: { transaction } })
        .then((response) => {
          notificationStore.notify(response.message, 'success');
          this.fetch().then(() => responseResolve());
        }).catch((error) => {
        notificationStore.notify(error.body.message, 'danger');
      });

      return returnPromise;
    },

    remove(id) {
      this.transactions = this.transactions.filter(transaction => transaction.id !== id);
    },
    setTransactionType(newType) {
      this.excludeCredits = newType === DEBIT_TRANSACTION;
      this.excludeDebits = newType === CREDIT_TRANSACTION;
    },

    setTransactionIdForFormModal(id) {
      this.transactionIdForFormModal = id;
    },
  }
});
