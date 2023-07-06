import { defineStore } from 'pinia'
import { transactions as transactionsApi } from '~/api';

export default defineStore('transaction', {
  state: () => ({
    transactions: [],
    daysToShow: 30,
    excludeDebits: false,
    excludeCredits: false,
  }),
  actions: {
    fetchTransactions() {
      const params = {
        daysToShow: this.daysToShow,
        excludeDebits: this.excludeDebits,
        excludeCredits: this.excludeCredits,
      };
      transactionsApi.list({ query: params }).then(response => this.transactions = response.transactions);
    },
  }
});
