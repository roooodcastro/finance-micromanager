import { defineStore } from 'pinia'

export default defineStore('transaction', {
  state: () => ({
    transactions: [],
  }),
});
