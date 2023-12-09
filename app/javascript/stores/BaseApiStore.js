import { defineStore } from 'pinia';

import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import I18n from '~/utils/I18n';

export function defineBaseApiStore(name, options = {}) {
  const dynamicGetters = {};
  dynamicGetters[`${options.resourceName}ForFormModal`] = (state) => {
    // Clone the object so it doesn't affect the list before it's actually updated
    return { ...(state[options.resourcesName].find(resource => resource.id === state.idForFormModal) ?? {}) };
  };

  return defineStore(name, {
    state: () => ({
      idForFormModal: null,
      fetchParams: {},
      ...options.state,
    }),
    getters: {
      ...dynamicGetters,
      ...options.getters,
    },
    actions: {
      openFormModal(id) {
        const modalStore = useModalStore();
        this.idForFormModal = id;
        modalStore.show(options.formId);
      },

      loadFromProps(records) {
        this[options.resourcesName] = records;
      },

      setFetchParams(params) {
        this.fetchParams = Object.assign(this.fetchParams, params);
      },

      fetch() {
        return options
          .api
          .index({ query: this.fetchParams })
          .then(response => this[options.resourcesName] = response[options.resourcesName]);
      },

      create(record) {
        const notificationStore = useNotificationStore();
        let responseResolve;
        const returnPromise = new Promise(resolve => responseResolve = resolve);
        const data = {}
        data[options.resourcesName] = record;

        options
          .api
          .create({ data })
          .then((response) => {
            this.fetch();
            notificationStore.notify(response.message, 'success');
            responseResolve();
          })
          .catch((error) => {
            const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
            notificationStore.notify(errorMessage, 'danger');
        });

        return returnPromise;
      },

      update(id, record) {
        const notificationStore = useNotificationStore();
        let responseResolve;
        const returnPromise = new Promise(resolve => responseResolve = resolve);
        const data = {}
        data[options.resourcesName] = record;

        options
          .api
          .update({ params: { id }, data })
          .then((response) => {
            this.fetch();
            notificationStore.notify(response.message, 'success');
            responseResolve();
          })
          .catch((error) => {
            const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
            notificationStore.notify(errorMessage, 'danger');
        });

        return returnPromise;
      },

      ...options.actions,
    },
  });
}
