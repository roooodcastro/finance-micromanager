import { defineStore, storeToRefs } from 'pinia';
import dayjs from 'dayjs';

import useNotificationStore from '~/stores/NotificationStore.js';
import useBrowserCacheStore from '~/stores/BrowserCacheStore.js';
import useModalStore from '~/stores/ModalStore.js';
import I18n from '~/utils/I18n.js';
import { BROWSER_CACHE_NAME } from '~/utils/Constants.js';

export function defineBaseApiStore(name, storeOptions = {}) {
  const dynamicState = {};
  dynamicState[`${storeOptions.resourceName}ForFormModal`] = {};

  const fetchCollectionFromApi = (store) => {
    // console.log(`Fetching ${storeOptions.resourcesName} from API`);

    store.loading = true;
    return storeOptions
      .api
      .index(Object.assign(store.urlParams, { query: store.fetchParams }))
      .then(response => store[storeOptions.resourcesName] = response[storeOptions.resourcesName])
      .finally(() => {
        store.loading = false;
        store.initialFetchDone = true;
      });
  };

  const fetchCollectionFromCache = (store) => {
    // console.log(`Fetching ${storeOptions.resourcesName} from cache`);
    const path = storeOptions.api.index.path(Object.assign(store.urlParams, { query: store.fetchParams }));

    return caches.open(BROWSER_CACHE_NAME).then((cache) => {
      return cache.match(path).then((response) => {
        if (response) {
          // console.log(`Cache HIT for ${storeOptions.resourcesName}`);
          return response.json().then((jsonResponse) => {
            store[storeOptions.resourcesName] = jsonResponse[storeOptions.resourcesName];
          }).finally(() => {
            store.loading = false;
            store.initialFetchDone = true;
          });
        }

        // console.log(`Cache MISS for ${storeOptions.resourcesName}, fetching from API instead`);
        return fetchCollectionFromApi(store);
      });
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
      lastUpdatedAt: () => {
        const { updatedAtValues } = storeToRefs(useBrowserCacheStore());

        return updatedAtValues.value[storeOptions.resourceName];
      },
    },
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
        if (this.lastUpdatedAt && this.lastUpdatedAt < dayjs()) {
          return fetchCollectionFromCache(this);
        } else {
          return fetchCollectionFromApi(this);
        }
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
            responseReject(error);
          });

        return returnPromise;
      },

      ...storeOptions.actions,
    },
  });
}
