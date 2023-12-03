<template>
  <div
    :id="TRANSACTION_FORM_MODAL_ID"
    ref="transactionFormModal"
    class="modal fade"
    tabindex="-1"
    :aria-labelledby="title"
    aria-hidden="true"
  >
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ title }}
          </h5>
          <CloseButton dismiss="modal" />
        </div>
        <div
          v-if="transaction"
          class="modal-body"
        >
          <TransactionForm
            :transaction="transaction"
            @close="handleFormClose"
          />
        </div>
        <div class="TransactionFormModal__footer d-grid d-lg-flex gap-2 modal-footer">
          <button
            type="button"
            class="btn btn-outline-secondary"
            data-bs-dismiss="modal"
          >
            <FontAwesomeIcon
              :icon="['far', 'circle-xmark']"
              class="me-2"
            />

            {{ t('cancel') }}
          </button>
          <button
            type="submit"
            :form="TRANSACTION_FORM_ID"
            class="btn btn-primary"
          >
            <FontAwesomeIcon
              icon="floppy-disk"
              class="me-lg-2"
            />

            {{ t('submit') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import { Modal as BootstrapModal } from 'bootstrap';

import I18n from '~/utils/I18n';
import useTransactionStore from '~/stores/TransactionStore.js';
import { TRANSACTION_FORM_ID, TRANSACTION_FORM_MODAL_ID } from '~/utils/Constants.js';

import CloseButton from '~/components/bootstrap/CloseButton.vue';
import TransactionForm from '~/components/transactions/TransactionForm.vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    CloseButton,
    FontAwesomeIcon,
    TransactionForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.transactions.form');

    const bootstrapModal = ref(null);
    const transactionFormModal = ref(null);

    onMounted(() => bootstrapModal.value = new BootstrapModal(transactionFormModal.value));

    const transactionStore = useTransactionStore();
    const { transactionForFormModal: transaction } = storeToRefs(transactionStore);

    const isNewRecord = computed(() => !transaction.value?.id);
    const title = computed(() => isNewRecord.value ? t('new_title') : t('edit_title'));

    const handleFormClose = () => bootstrapModal.value.hide();

    return {
      t,
      transactionFormModal,
      transaction,
      title,
      handleFormClose,
      TRANSACTION_FORM_ID,
      TRANSACTION_FORM_MODAL_ID,
    }
  },
};
</script>

<style lang="scss" scoped>
.TransactionFormModal__footer {
  grid-template-columns: repeat(2, 1fr);
}
</style>
