<template>
  <div
    :id="CONFIRMATION_MODAL_ID"
    class="modal"
    tabindex="-1"
  >
    <div class="modal-dialog modal-sm">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ confirmation.title ?? t('confirmation_title') }}
          </h5>
        </div>
        <div class="modal-body">
          {{ confirmation.message }}
        </div>
        <div class="modal-footer">
          <button
            type="button"
            class="btn btn-outline-secondary"
            data-bs-dismiss="modal"
            @click="handleResponse(false)"
          >
            {{ t('confirmation_no') }}
          </button>
          <button
            type="button"
            class="btn btn-primary"
            data-bs-dismiss="modal"
            @click="handleResponse(true)"
          >
            {{ t('confirmation_yes') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.Js';
import useModalStore from '~/stores/ModalStore.js';
import { CONFIRMATION_MODAL_ID } from '~/utils/Constants.js';

export default {
  setup() {
    const modalStore = useModalStore();
    const { confirmation } = storeToRefs(modalStore);

    const handleResponse = (response) => {
      if (response) {
        confirmation.value.responseConfirm();
      } else {
        confirmation.value.responseReject();
      }
    }

    return {
      t: I18n.scopedTranslator('views.layout.rails'),
      CONFIRMATION_MODAL_ID,
      confirmation,
      handleResponse,
    }
  }
};
</script>
