import { storeToRefs } from 'pinia';

import { importNames as importNamesApi } from '~/api/all.js';
import { IMPORT_NAME_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';
import { isMediaBreakpointDown } from '~/utils/ResponsivenessUtils.js';

import usePaginationStore from '~/stores/PaginationStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';

import I18n from '~/utils/I18n.js';

export default defineBaseApiStore('importName', {
  resourceName: 'importName',
  resourcesName: 'importNames',
  formId: IMPORT_NAME_FORM_ID,
  api: importNamesApi,

  state: {
    importNames: [],
    importName: null,
    fetchParams: {},
    loading: false,
  },

  actions: {
    fetchCollection(options = {}) {
      this.loading = true;
      const paginationStore = usePaginationStore();
      const { pagination } = storeToRefs(paginationStore);
      const keepRecords = options.keepRecords;
      delete options.keepRecords;

      // This means that it's a mobile layout (with infinite scrolling), and this is not a fetch from
      // infinite scrolling, so we must reset the page back to 1 otherwise we'll end up with missing records.
      if (!keepRecords && isMediaBreakpointDown('md')) {
        pagination.value.page = 1;
      }

      return importNamesApi
        .index({ query: Object.assign(this.fetchParams, pagination.value) })
        .then((response) => {
          keepRecords
            ? this.importNames.push(...response.importNames)
            : this.importNames = response.importNames;

            if (response.pagination) {
              pagination.value = response.pagination;
            }
        })
        .finally(() => this.loading = false);
    },

    destroy(id) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.import_names.confirmation.destroy') })
        .then(() => {
          importNamesApi
            .destroy({ id })
            .then((response) => {
              this.fetchCollection();
              notificationStore.notify(response.message, 'success');
              window.location.href = importNamesApi.index.path();
            })
            .catch((error) => {
              const errorMessage = error.body.message ?? I18n.t('views.layout.rails.generic_error');
              notificationStore.notify(errorMessage, 'danger');
            });
        })
        .catch(() => {});
    },
  },
});
