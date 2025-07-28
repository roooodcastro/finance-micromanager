<template>
  <div
    v-if="massEditMode"
    class="card my-2 bg-secondary-subtle"
    :class="{ 'mx-2': cardBody }"
  >
    <h6 class="mx-2 mt-2 d-flex justify-content-between flex-wrap">
      <span>{{ t('mass_editing') }}</span>
      <span>{{ t('mass_edit_selected', { count: massEditTransactionIdsCount }) }}</span>
    </h6>

    <div class="d-flex p-2 gap-2 justify-content-between flex-wrap">
      <div class="d-flex gap-2">
        <a
          class="btn btn-xs btn-light flex-grow-1 flex-lg-grow-0"
          @click="handleSelectAll"
        >
          {{ t('mass_edit_select_all') }}
        </a>

        <a
          class="btn btn-xs btn-light flex-grow-1 flex-lg-grow-0"
          @click="handleDeselectAll"
        >
          {{ t('mass_edit_deselect_all') }}
        </a>
      </div>

      <div class="d-flex gap-2 flex-grow-1 flex-lg-grow-0">
        <a
          class="btn btn-xs btn-light flex-grow-1 flex-lg-grow-0"
          @click="handleCancelMassEdit"
        >
          {{ t('mass_edit_cancel') }}
        </a>
        <a
          class="btn btn-xs btn-primary flex-grow-1 flex-lg-grow-0"
          :class="{ 'disabled': massEditTransactionIdsCount === 0 }"
          @click="handleSubmitMassEdit"
        >
          {{ t('mass_edit_submit') }}
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';

export default {
  setup() {
    const transactionStore = useTransactionStore();

    const {
      massEditMode,
      massEditTransactionIdsCount,
    } = storeToRefs(transactionStore);

    const handleCancelMassEdit = transactionStore.cancelMassEditMode;
    const handleDeselectAll = transactionStore.deselectAllMassEditMode;
    const handleSelectAll = transactionStore.selectAllMassEditMode;
    const handleSubmitMassEdit = transactionStore.submitMassEdit;

    return {
      massEditMode,
      massEditTransactionIdsCount,
      handleCancelMassEdit,
      handleDeselectAll,
      handleSelectAll,
      handleSubmitMassEdit,
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>

