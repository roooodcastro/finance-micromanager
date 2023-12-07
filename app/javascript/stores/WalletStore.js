import { defineStore } from 'pinia';

import { wallets as walletsApi } from '~/api';
import useNotificationStore from '~/stores/NotificationStore.js';

export default defineStore('wallet', {
  state: () => ({
    wallets: [],
    idForFormModal: null,
  }),
  getters: {
    walletForFormModal: (state) => {
      // Clone the object so it doesn't affect the list before it's actually updated
      return { ...(state.wallets.find(wallet => wallet.id === state.idForFormModal) ?? {}) };
    },
  },
  actions: {
    loadFromProps(wallets) {
      this.wallets = wallets;
    },
    setIdForFormModal(id) {
      this.idForFormModal = id;
    },
    fetch(options = {}) {
      walletsApi
        .index({ query: options })
        .then(response => this.wallets = response.wallets);
    },

    create(wallet) {
      const notificationStore = useNotificationStore();
      let responseResolve;
      const returnPromise = new Promise(resolve => responseResolve = resolve);

      walletsApi
        .create({ data: { wallet } })
        .then((response) => {
          this.fetch();
          notificationStore.notify(response.message, 'success');
          responseResolve();
        }).catch((error) => {
        notificationStore.notify(error.body.message, 'danger');
      });

      return returnPromise;
    },

    update(id, wallet) {
      const notificationStore = useNotificationStore();
      let responseResolve;
      const returnPromise = new Promise(resolve => responseResolve = resolve);

      walletsApi
        .update({ params: { id }, data: { wallet } })
        .then((response) => {
          this.fetch();
          notificationStore.notify(response.message, 'success');
          responseResolve();
        }).catch((error) => {
        notificationStore.notify(error.body.message, 'danger');
      });

      return returnPromise;
    },
  },
});
