import { importsImportTransactions as importTransactionsApi } from '~/api/all.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

export default defineBaseApiStore('importTransaction', {
  resourceName: 'importTransaction',
  resourcesName: 'importTransactions',
  formId: null,
  api: importTransactionsApi,

  state: {
    importTransactions: [],
    importTransaction: null,
    fetchParams: {},
    urlParams: {},
  },

  actions: {
    moveCursorFromShortcut(amount) {
      const activeElement = document.activeElement;

      if (activeElement.attributes['data-transaction-input']) {
        const currentRow = parseInt(activeElement.attributes['data-row'].value);
        const inputType = activeElement.attributes['data-transaction-input'].value;
        const nextRow = currentRow + amount;
        const nextInput = document.querySelector(`[data-transaction-input="${inputType}"][data-row="${nextRow}"]`);

        if (nextInput) {
          if (nextInput.disabled) {
            this.movePreviewCursor(amount > 0 ? amount + 1 : amount - 1);
          } else {
            nextInput.focus();
          }
        }
      }
    },

    setActionFromShortcut(action) {
      const activeElement = document.activeElement;

      if (activeElement.attributes['data-transaction-input']) {
        const currentRow = parseInt(activeElement.attributes['data-row'].value);
        const importTransactionId = this.importTransactions[currentRow].id;
        this.update(importTransactionId, { id: importTransactionId, action });
      }
    }
  },
});
