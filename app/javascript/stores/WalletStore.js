import I18n from '~/utils/I18n.js';
import { wallets as walletsApi } from '~/api';
import useNotificationStore from '~/stores/NotificationStore.js';
import { WALLET_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

export default defineBaseApiStore('wallet', {
  resourceName: 'wallet',
  resourcesName: 'wallets',
  formId: WALLET_FORM_ID,
  api: walletsApi,

  state: {
    wallets: [],
    idForFormModal: null,
    fetchParams: {
      showDisabled: false,
    },
  },
  getters: {
    activeWallets: (state) => state.wallets.filter(wallet => !wallet.disabledAt),
    showDisabled: state => state.fetchParams.showDisabled,
  },
  actions: {
    disable(id) {
      const notificationStore = useNotificationStore();

      walletsApi
        .destroy({ id })
        .then((response) => {
          this.fetch();
          notificationStore.notify(response.message, 'success');
        })
        .catch(() => notificationStore.notify(I18n.t('views.layout.rails.generic_error'), 'danger'));
    },

    reenable(id) {
      const notificationStore = useNotificationStore();

      walletsApi
        .reenable({ id })
        .then((response) => {
          this.fetch();
          notificationStore.notify(response.message, 'success');
        })
        .catch(() => notificationStore.notify(I18n.t('views.layout.rails.generic_error'), 'danger'));
    }
  },
});
