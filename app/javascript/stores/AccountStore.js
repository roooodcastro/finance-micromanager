import { defineStore } from 'pinia'

export default defineStore('account', {
  state: () => ({
    currentAccount: {},
    availableAccounts: [],
  }),
});
