import { defineStore } from 'pinia'
import walletsApi from '~/api/WalletsApi';

export default defineStore('wallet', {
  state: () => ({
    currentWallet: {},
    availableWallets: [],
    walletIdForInviteModal: null,
  }),
  getters: {
    walletForInviteModal: (state) => {
      return state.availableWallets.find(wallet => wallet.id === state.walletIdForInviteModal);
    }
  },
  actions: {
    fetchAvailableWallets() {
      walletsApi.index().then((response) => {
        this.availableWallets = response.wallets;
      });
    },
    setWalletIdForInviteModal(walletId) {
      this.walletIdForInviteModal = walletId;
    },
  },
});
