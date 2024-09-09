import { _ } from 'lodash';

import I18n from '~/utils/I18n.js';
import Csrf from '~/utils/Csrf.js';
import { imports as importsApi, importsImportTransactions as importTransactionsApi } from '~/api/all.js';
import { IMPORT_FORM_ID } from '~/utils/Constants.js';
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
    importTransactions: [],
    fetchParams: {},
  },

  getters: {
    getImportTransaction: (state) => {
      return id => state.importTransactions.find(transaction => transaction.id === id);
    },
  },

  actions: {
    loadImportTransactionsFromProps(importObject, importTransactions) {
      this.importTransactions = importTransactions;
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

    updateImportTransaction(importTransaction) {
      const notificationStore = useNotificationStore();

      let responseResolve;
      let responseReject;
      const returnPromise = new Promise((resolve, reject) => {
        responseResolve = resolve;
        responseReject = reject;
      });

      importTransactionsApi
        .update({ params: { id: importTransaction.id }, data: { import_transaction: importTransaction } })
        .then((response) => {
          // console.log(response.message); TODO: give visual feedback that this happened
          this.importTransactions = this.importTransactions.map((importTransaction) => {
            if (importTransaction.id === response.importTransaction.id) {
              return response.importTransaction;
            } else {
              return importTransaction;
            }
          });
          responseResolve();
        }).catch((error) => {
          notificationStore.notify(error.body.message, 'danger');
          responseReject(error);
        });

      return returnPromise;
    },
  },
});
