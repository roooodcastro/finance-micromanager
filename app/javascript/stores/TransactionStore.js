import { defineStore } from 'pinia';
import _ from 'lodash';

import { transactions as transactionsApi } from '~/api';

export default defineStore('transaction', {
  state: () => ({
    transactions: [],
    pagination: {},
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
    fetchTransactions() {
      const params = {
        daysToShow: this.daysToShow,
        excludeDebits: this.excludeDebits,
        excludeCredits: this.excludeCredits,
        page: this.pagination.page,
      };
      transactionsApi
        .index({ query: params })
        .then((response) => {
          this.transactions = response.transactions;
          this.pagination = response.pagination;
        });
    },
    changePage(page) {
      this.pagination.page = page;
      this.fetchTransactions();
    },
  }
});
