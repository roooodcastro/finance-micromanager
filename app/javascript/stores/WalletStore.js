import { defineStore } from 'pinia';

import { wallets as walletsApi } from '~/api';
import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { WALLET_FORM_ID } from '~/utils/Constants.js';

export default defineStore('wallet', {
  state: () => ({
    wallets: [],
    idForFormModal: null,
    fetchParams: {
      showDisabled: false,
    },
  }),
  getters: {
    walletForFormModal: (state) => {
      // Clone the object so it doesn't affect the list before it's actually updated
      return { ...(state.wallets.find(wallet => wallet.id === state.idForFormModal) ?? {}) };
    },
    showDisabled: state => state.fetchParams.showDisabled,
  },
  actions: {
    openFormModal(id) {
      const modalStore = useModalStore();
      this.idForFormModal = id;
      modalStore.show(WALLET_FORM_ID);
    },

    loadFromProps(wallets) {
      this.wallets = wallets;
    },

    setFetchParams(params) {
      this.fetchParams = Object.assign(this.fetchParams, params);
    },

    fetch() {
      walletsApi.index({ query: this.fetchParams }).then(response => this.wallets = response.wallets);
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
