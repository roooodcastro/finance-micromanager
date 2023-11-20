import { defineStore } from 'pinia'
import accountsApi from '~/api/AccountsApi';

export default defineStore('account', {
  state: () => ({
    currentAccount: {},
    availableAccounts: [],
  }),
  actions: {
    fetchAvailableAccounts() {
      accountsApi.index().then((response) => {
        this.availableAccounts = response.accounts;
      });
    },
  },
});
