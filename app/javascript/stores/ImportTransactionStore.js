import { importsImportTransactions as importTransactionsApi } from '~/api/all.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

import { MATCH_TRANSACTION_SELECTOR_MODAL_ID } from '~/utils/Constants.js';
import useModalStore from '~/stores/ModalStore.js';

export default defineBaseApiStore('importTransaction', {
  resourceName: 'importTransaction',
  resourcesName: 'importTransactions',
  formId: null,
  api: importTransactionsApi,

  state: {
    importTransactions: [],
    importTransaction: null,
    importTransactionIdForMatchSelector: null,
    fetchParams: {},
    urlParams: {},
  },

  getters: {
    importTransactionForMatchSelector: (state) => {
      return state.importTransactions.find((importTransaction) => {
        return importTransaction.id === state.importTransactionIdForMatchSelector;
      });
    },
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
    },

    openMatchTransactionSelectorModal(importTransactionId) {
      this.importTransactionIdForMatchSelector = importTransactionId;
      const modalStore = useModalStore();
      modalStore.show(MATCH_TRANSACTION_SELECTOR_MODAL_ID);
    },

    closeMatchTransactionSelectorModal() {
      const modalStore = useModalStore();
      modalStore.hide(MATCH_TRANSACTION_SELECTOR_MODAL_ID);
    }
  },
});
