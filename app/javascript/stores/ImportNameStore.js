import { importNames as importNamesApi } from '~/api/all.js';
import { IMPORT_NAME_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';
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
  },

  actions: {
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
