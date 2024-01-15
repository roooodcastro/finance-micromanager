import { defineStore } from 'pinia';

import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import I18n from '~/utils/I18n.js';

export function defineBaseApiStore(name, storeOptions = {}) {
  const dynamicState = {};
  dynamicState[`${storeOptions.resourceName}ForFormModal`] = {};

  return defineStore(name, {
    state: () => ({
      initialFetchDone: false,
      loading: false,
      actionName: null,
      idForFormModal: null,
      urlParams: {},
      fetchParams: {},
      ...dynamicState,
      ...storeOptions.state,
    }),
    getters: { ...storeOptions.getters },
    actions: {
      openFormModal(id) {
        const modalStore = useModalStore();
        this.idForFormModal = id ?? crypto.randomUUID();

        const existingRecord = this[storeOptions.resourceName] ?? this[storeOptions.resourcesName]
          .find(resource => resource.id === this.idForFormModal);

        if (existingRecord) {
          // Clone the object so it doesn't affect the list before it's actually updated
          this[`${storeOptions.resourceName}ForFormModal`] = { ...existingRecord };
        } else {
          this[`${storeOptions.resourceName}ForFormModal`] = { _id: this.idForFormModal };
        }

        modalStore.show(storeOptions.formId);
      },

      loadCollectionFromProps(records) {
        this[storeOptions.resourcesName] = records;
        this.initialFetchDone = true;
      },

      setActionName(actionName) {
        this.actionName = actionName;
      },

      setFetchParams(params) {
        this.fetchParams = Object.assign(this.fetchParams, params);
      },

      fetch(id, options) {
        if (options.fetchSingle) {
          this.fetchSingle(id);
        }
        if (!('fetchCollection' in options) || options.fetchCollection) {
          this.fetchCollection();
        }
      },

      fetchCollection() {
        this.loading = true;
        return storeOptions
          .api
          .index(Object.assign(this.urlParams, { query: this.fetchParams }))
          .then(response => this[storeOptions.resourcesName] = response[storeOptions.resourcesName])
          .finally(() => {
            this.loading = false;
            this.initialFetchDone = true;
          });
      },

      fetchSingle(id) {
        this.loading = true;
        return storeOptions
          .api
          .show({ id })
          .then(response => this[storeOptions.resourceName] = response[storeOptions.resourceName])
          .finally(() => {
            this.loading = false;
            this.initialFetchDone = true;
          });
      },

      create(record, options = {}) {
        const notificationStore = useNotificationStore();
        let responseResolve;
        const returnPromise = new Promise(resolve => responseResolve = resolve);
        const data = {}
        data[storeOptions.resourceName] = record;

        storeOptions
          .api
          .create({ params: this.urlParams, data })
          .then((response) => {
            // Update resource list
            this.fetch(null, options);

            // Reset resourceForFormModal
            this[`${storeOptions.resourceName}ForFormModal`] = {};
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

      update(id, record, options = {}) {
        const notificationStore = useNotificationStore();
        let responseResolve;
        const returnPromise = new Promise(resolve => responseResolve = resolve);
        const data = {};
        data[storeOptions.resourceName] = record;

        storeOptions
          .api
          .update({ params: Object.assign(this.urlParams, { id }), data })
          .then((response) => {
            this.fetch(id, options);
            notificationStore.notify(response.message, 'success');
            responseResolve();
          })
          .catch((error) => {
            const errorMessage = error?.body?.message ?? I18n.t('views.layout.rails.generic_error');
            notificationStore.notify(errorMessage, 'danger');
          });

        return returnPromise;
      },

      ...storeOptions.actions,
    },
  });
}
