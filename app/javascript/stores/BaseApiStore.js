import { defineStore, storeToRefs } from 'pinia';

import useNotificationStore from '~/stores/NotificationStore.js';
import useBrowserCacheStore from '~/stores/BrowserCacheStore.js';
import useModalStore from '~/stores/ModalStore.js';
import I18n from '~/utils/I18n.js';
import { fetchFromCache } from '~/utils/BrowserCacheUtils.js';

export function defineBaseApiStore(name, storeOptions = {}) {
  const dynamicState = {};
  dynamicState[`${storeOptions.resourceName}ForFormModal`] = {};

  const setShowPageHref = (collection) => {
    collection.forEach((record) => {
      const showPageHref = storeOptions.api.show?.path({ id: record.id });
      if (showPageHref) {
        record.href = showPageHref;
      }
    });
  }

  const fetchCollectionFromApi = (store) => {
    store.loading = true;
    return storeOptions
      .api
      .index(Object.assign(store.urlParams, { query: store.fetchParams }))
      .then((response) => {
        const newCollection = response[storeOptions.resourcesName];
        setShowPageHref(newCollection);
        store[storeOptions.resourcesName] = newCollection;
      })
      .finally(() => {
        store.loading = false;
        store.initialFetchDone = true;
      });
  };

  const fetchCollectionFromCache = (store) => {
    const path = storeOptions.api.index.path(Object.assign(store.urlParams, { query: store.fetchParams }));

    return fetchFromCache(path, store.latestUpdatedAt)
      .then((data) => {
        const collection = data[storeOptions.resourcesName];
        setShowPageHref(collection);
        store[storeOptions.resourcesName] = collection;
      })
      .catch(() => fetchCollectionFromApi(store))
      .finally(() => {
        store.loading = false;
        store.initialFetchDone = true;
      });
  };

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
    getters: {
      ...storeOptions.getters,
      latestUpdatedAt: () => {
        const { latestUpdatedAtValues } = storeToRefs(useBrowserCacheStore());

        return latestUpdatedAtValues.value[storeOptions.resourceName];
      },
    },
    actions: {
      openFormModal(id, record = null) {
        const modalStore = useModalStore();
        this.idForFormModal = id ?? crypto.randomUUID();

        const existingRecord = this[storeOptions.resourceName] ?? this[storeOptions.resourcesName]
          .find(resource => resource.id === this.idForFormModal);

        if (existingRecord) {
          // Clone the object so it doesn't affect the list before it's actually updated
          this[`${storeOptions.resourceName}ForFormModal`] = { ...existingRecord };
        } else if (record) {
          this[`${storeOptions.resourceName}ForFormModal`] = { ...record };
        } else {
          this[`${storeOptions.resourceName}ForFormModal`] = { _id: this.idForFormModal };
        }

        modalStore.show(storeOptions.formId);
      },

      loadCollectionFromProps(records) {
        setShowPageHref(records);
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

      fetchCollection(options = {}) {
        if (this.latestUpdatedAt && !options.overrideCache) {
          return fetchCollectionFromCache(this);
        } else {
          return fetchCollectionFromApi(this);
        }
      },

      fetchSingle(id) {
        if (!storeOptions.api.show) {
          return Promise.resolve();
        }

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
        let responseReject;
        const returnPromise = new Promise((resolve, reject) => {
          responseResolve = resolve;
          responseReject = reject;
        });

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
            responseReject(error);
        });

        return returnPromise;
      },

      update(id, record, options = {}) {
        const notificationStore = useNotificationStore();

        let responseResolve;
        let responseReject;
        const returnPromise = new Promise((resolve, reject) => {
          responseResolve = resolve;
          responseReject = reject;
        });

        const data = {};
        data[storeOptions.resourceName] = record;
        const idParam = !!id && (typeof id === 'object') ? id : { id };

        storeOptions
          .api
          .update({ params: Object.assign(this.urlParams, idParam), data })
          .then((response) => {
            this.fetch(id, options);
            notificationStore.notify(response.message, 'success');
            responseResolve();
          })
          .catch((error) => {
            const errorMessage = error?.body?.message ?? I18n.t('views.layout.rails.generic_error');
            notificationStore.notify(errorMessage, 'danger');
            responseReject(error);
          });

        return returnPromise;
      },

      ...storeOptions.actions,
    },
  });
}
