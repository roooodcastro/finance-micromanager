import { defineStore } from 'pinia'
import accountsApi from '~/api/AccountsApi';

export default defineStore('account', {
  state: () => ({
    currentAccount: {},
    availableAccounts: [],
    accountIdForInviteModal: null,
  }),
  getters: {
    accountForInviteModal: (state) => {
      return state.availableAccounts.find(account => account.id === state.accountIdForInviteModal);
    }
  },
  actions: {
    fetchAvailableAccounts() {
      accountsApi.index().then((response) => {
        this.availableAccounts = response.accounts;
      });
    },
    setAccountIdForInviteModal(accountId) {
      this.accountIdForInviteModal = accountId;
    },
  },
});
