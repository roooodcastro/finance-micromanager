import { _ } from 'lodash';

import I18n from '~/utils/I18n.js';
import Csrf from '~/utils/Csrf.js';
import { imports as importsApi } from '~/api/all.js';
import { IMPORT_FORM_ID, IMPORT_PREVIEW_SAVE_STATES } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';

export default defineBaseApiStore('import', {
  resourceName: 'import',
  resourcesName: 'imports',
  formId: IMPORT_FORM_ID,
  api: importsApi,

  state: {
    imports: [],
    import: null,
    fetchParams: {},
    previewSaveState: IMPORT_PREVIEW_SAVE_STATES.saved,
  },

  actions: {
    loadImportFromProps(importObject) {
      this.import = importObject;
    },

    create(record, options = {}) {
      const notificationStore = useNotificationStore();

      let responseResolve;
      let responseReject;
      const returnPromise = new Promise((resolve, reject) => {
        responseResolve = resolve;
        responseReject = reject;
      });

      const formData = new FormData();
      Object
        .keys(record)
        .filter(key => key !== 'sourceFile')
        .forEach(key => formData.append(`import[${_.snakeCase(key)}]`, record[key]));

      formData.append('import[source_file]', record.sourceFile, record.sourceFile.name);

      fetch(importsApi.create.path(), {
        method: 'POST',
        headers: { 'X-CSRF-Token': Csrf.getToken() },
        body: formData,
      }).then((response) => {
        if (response.status >= 200 && response.status < 300) {
          response.json().then((jsonResponse) => {
            // Update resource list
            this.fetch(null, options);

            // Reset resourceForFormModal
            this.importForFormModal = {};
            this.idForFormModal = null;

            // Notify and resolve
            notificationStore.notify(jsonResponse.message, 'success');
            responseResolve(jsonResponse);
          });
        } else {
          response.json().then((jsonResponse) => {
            const errorMessage = jsonResponse.message ?? I18n.t('views.layout.rails.generic_error');
            notificationStore.notify(errorMessage, 'danger');
            responseReject(jsonResponse);
          });
        }
      });

      return returnPromise;
    },
  },
});
