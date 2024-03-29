import { defineStore } from 'pinia'

import I18n from '~/utils/I18n.js';
import { settings as settingsApi } from '~/api/all.js';
import useNotificationStore from '~/stores/NotificationStore.js';

export default defineStore('user', {
  state: () => ({
    user: null,
  }),

  getters: {
    isUserLoggedIn: (state) => !!state.user,
    nameInitials: (state) => {
      if (!state.user) return '';

      const fullNameParts = state.user.fullName.split(' ');

      if (fullNameParts.length >= 1) {
        return fullNameParts[0].slice(0, 1).toUpperCase();
      } else {
        return state.user.email.slice(0, 1).toUpperCase();
      }
    },
  },

  actions: {
    fetchCollection() {
      return settingsApi.show().then(response => this.user = response.user);
    },

    updateSettings(userAttributes) {
      const notificationStore = useNotificationStore();

      let responseResolve;
      let responseReject;
      const returnPromise = new Promise((resolve, reject) => {
        responseResolve = resolve;
        responseReject = reject;
      });

      settingsApi
        .update({ data: { user: userAttributes } })
        .then((response) => {
          this.fetchCollection().then(responseResolve);
          notificationStore.notify(response.message, 'success');
        })
        .catch((error) => {
          const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
          notificationStore.notify(errorMessage, 'danger');
          responseReject(error);
        });

      return returnPromise;
    },
  },
});
