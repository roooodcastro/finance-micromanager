import { defineStore } from 'pinia';

import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import I18n from '~/utils/I18n.js';

export function defineBaseApiStore(name, options = {}) {
  const dynamicState = {};

  dynamicState[`${options.resourceName}ForFormModal`] = {};

  return defineStore(name, {
    state: () => ({
      idForFormModal: null,
      urlParams: {},
      fetchParams: {},
      ...dynamicState,
      ...options.state,
    }),
    getters: { ...options.getters },
    actions: {
      openFormModal(id) {
        const modalStore = useModalStore();
        this.idForFormModal = id ?? crypto.randomUUID();

        const existingRecord = this[options.resourcesName].find(resource => resource.id === this.idForFormModal);

        if (existingRecord) {
          // Clone the object so it doesn't affect the list before it's actually updated
          this[`${options.resourceName}ForFormModal`] = { ...existingRecord };
        } else {
          this[`${options.resourceName}ForFormModal`] = { _id: this.idForFormModal };
        }

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
          .index(Object.assign(this.urlParams, { query: this.fetchParams }))
          .then(response => this[options.resourcesName] = response[options.resourcesName]);
      },

      create(record) {
        const notificationStore = useNotificationStore();
        let responseResolve;
        const returnPromise = new Promise(resolve => responseResolve = resolve);
        const data = {}
        data[options.resourceName] = record;

        options
          .api
          .create({ params: this.urlParams, data })
          .then((response) => {
            // Update resource list
            this.fetch();

            // Reset resourceForFormModal
            this[`${options.resourceName}ForFormModal`] = {};
            this.idForFormModal = null;

            // Notify and resolve
            notificationStore.notify(response.message, 'success');
            responseResolve(response);
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
        data[options.resourceName] = record;

        options
          .api
          .update({ params: Object.assign(this.urlParams, { id }), data })
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
