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
    fetchTransactions(options = {}) {
      const defaultOptions = {
        daysToShow: this.daysToShow,
        excludeDebits: this.excludeDebits,
        excludeCredits: this.excludeCredits,
        page: this.pagination.page,
      };
      transactionsApi
        .index({ query: Object.assign(defaultOptions, options) })
        .then((response) => {
          this.transactions = response.transactions;
          this.pagination = response.pagination;
        });
    },
    fetchNextPage() {
      if (this.pagination.page < this.pagination.pages) {
        const params = {
          daysToShow: this.daysToShow,
          excludeDebits: this.excludeDebits,
          excludeCredits: this.excludeCredits,
          page: this.pagination.page + 1,
        };
        return transactionsApi
          .index({ query: params })
          .then((response) => {
            this.transactions.push(...response.transactions);
            this.pagination = response.pagination;
          });
      } else {
        return Promise.resolve();
      }
    },
    remove(id) {
      this.transactions = this.transactions.filter(transaction => transaction.id !== id);
    },
    changePage(page) {
      this.pagination.page = page;
      this.fetchTransactions();
    },
  }
});
