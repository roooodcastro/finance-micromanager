import { defineStore } from 'pinia';
import _ from 'lodash';

import { transactions as transactionsApi } from '~/api';

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
    fetchTransactions() {
      const params = {
        daysToShow: this.daysToShow,
        excludeDebits: this.excludeDebits,
        excludeCredits: this.excludeCredits,
      };
      transactionsApi.index({ query: params }).then(response => this.transactions = response.transactions);
    },
  }
});
