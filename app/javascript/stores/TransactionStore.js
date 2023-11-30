import { defineStore, storeToRefs } from 'pinia';
import _ from 'lodash';

import usePaginationStore from '~/stores/PaginationStore.js';
import { transactions as transactionsApi } from '~/api';
import { DEBIT_TRANSACTION, CREDIT_TRANSACTION } from '~/utils/Constants.js';

export default defineStore('transaction', {
  state: () => ({
    transactions: [],
    daysToShow: 30,
    excludeDebits: false,
    excludeCredits: false,
  }),
  getters: {
    groupedTransactions: state => {
      return _.groupBy(state.transactions, 'transactionDate');
    }
  },
  actions: {
    fetchTransactions(options = {}) {
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
    remove(id) {
      this.transactions = this.transactions.filter(transaction => transaction.id !== id);
    },
    setTransactionType(newType) {
      this.excludeCredits = newType === DEBIT_TRANSACTION;
      this.excludeDebits = newType === CREDIT_TRANSACTION;
    },
  }
});
