import { defineStore } from 'pinia';
import { Modal as BootstrapModal } from 'bootstrap';
import { CONFIRMATION_MODAL_ID } from '~/utils/Constants.js';

export default defineStore('modal', {
  state: () => ({
    confirmation: {},
  }),
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
  },
});
