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

  const fetchCollectionFromApi = (store, options = {}) => {
    store.loading = true;
    const fetchParams = { ...(store.urlParams || {}), ...{ query: {...store.fetchParams, ...(options?.fetchParams || {})} }};

    return storeOptions
      .api
      .index(fetchParams)
      .then((response) => {
        const newCollection = response[storeOptions.resourcesName];
        setShowPageHref(newCollection);
        if (options.targetVariable) {
          store[options.targetVariable] = newCollection;
        } else {
          store[storeOptions.resourcesName] = newCollection;
        }
      })
      .finally(() => {
        store.loading = false;
        store.initialFetchDone = true;
      });
  };

  const fetchCollectionFromCache = (store, options = {}) => {
    const fetchParams = { ...(store.urlParams || {}), ...{ query: {...store.fetchParams, ...(options?.fetchParams || {})} }};
    const path = storeOptions.api.index.path(fetchParams);

    return fetchFromCache(path, store.latestUpdatedAt)
      .then((data) => {
        const collection = data[storeOptions.resourcesName];
        setShowPageHref(collection);
        if (options.targetVariable) {
          store[options.targetVariable] = collection;
        } else {
          store[storeOptions.resourcesName] = collection;
        }
      })
      .catch(() => fetchCollectionFromApi(store, options))
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
          return this.fetchCollection();
        }
        return Promise.resolve();
      },

      fetchCollection(options = {}) {
        if (this.latestUpdatedAt && !options.overrideCache) {
          return fetchCollectionFromCache(this, options);
        } else {
          return fetchCollectionFromApi(this, options);
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
            this.fetch(id, options).then(() => {
              if (options.waitForFetch) {
                responseResolve();
              }
            });
            notificationStore.notify(response.message, 'success');
            if (!options.waitForFetch) {
              responseResolve();
            }
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
