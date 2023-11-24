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
    remove(id) {
      this.availableWallets = this.availableWallets.filter(wallet => wallet.id !== id);
    },
    setWalletIdForInviteModal(walletId) {
      this.walletIdForInviteModal = walletId;
    },
  },
});
