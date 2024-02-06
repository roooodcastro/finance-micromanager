import { defineStore } from 'pinia';
import { Modal as BootstrapModal } from 'bootstrap';
import { CONFIRMATION_MODAL_ID } from '~/utils/Constants.js';

export default defineStore('modal', {
  state: () => ({
    confirmation: {},
    modals: {},
  }),
  getters: {
    modalId: () => name => `${name}Modal`,
  },
  actions: {
    showConfirmationDialog(options) {
      let responseConfirm, responseReject;

      const resolveAction = new Promise((resolve, reject) => {
        responseConfirm = resolve;
        responseReject = reject;
      });

      const defaults = {
        show: true,
        responseConfirm,
        responseReject,
      };

      this.confirmation = { ...defaults, ...options };

      new BootstrapModal(`#${CONFIRMATION_MODAL_ID}`, { keyboard: false }).show();

      return resolveAction;
    },

    registerModal(name) {
      if (!this.modals[name]) {
        const modalId = name.endsWith('Modal') ? name : this.modalId(name);
        if (document.querySelector(`#${modalId}`)) {
          this.modals[name] = new BootstrapModal(`#${modalId}`);
        } else {
          /* eslint-disable-next-line no-console */
          console.error(`DOM element for modal #${modalId} not found. Is the modal component loaded?`);
        }
      }
    },

    show(name) {
      if (!this.modals[name]) {
        this.registerModal(name);
      }

      if (this.modals[name]) {
        this.modals[name].show();
      }
    },

    hide(name) {
      if (!this.modals[name]) {
        this.registerModal(name);
      }

      this.modals[name].hide();
    },
  },
});
