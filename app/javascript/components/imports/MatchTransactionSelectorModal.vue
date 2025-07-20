<template>
  <Draggable
    :id="MATCH_TRANSACTION_SELECTOR_MODAL_ID"
    class="modal fade"
    tabindex="-1"
    :aria-labelledby="t('title')"
    aria-hidden="true"
    draggable-element-selector=".modal-content"
    trigger-element-selector=".modal-header"
    v-on="{ 'hide.bs.modal': handleHide }"
  >
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ t('title') }}
          </h5>
          <CloseButton dismiss="modal" />
        </div>
        <MatchTransactionsList
          v-if="!!importTransaction"
          :import-transaction-id="importTransaction.id"
          :matches="matches"
        />

        <div class="d-grid d-lg-flex gap-2 modal-footer">
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
        </div>
      </div>
    </div>
  </Draggable>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import useImportTransactionStore from '~/stores/ImportTransactionStore.js';
import { MATCH_TRANSACTION_SELECTOR_MODAL_ID, IMPORT_ACTION_IMPORT } from '~/utils/Constants.js';

import CloseButton from '~/components/bootstrap/CloseButton.vue';
import Draggable from '~/components/ui/Draggable.vue';
import MatchTransactionsList from '~/components/imports/MatchTransactionsList.vue';

export default {
  components: {
    CloseButton,
    Draggable,
    FontAwesomeIcon,
    MatchTransactionsList,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.match_transaction_selector_modal');

    const importTransactionStore = useImportTransactionStore();
    const { importTransactionForMatchSelector: importTransaction } = storeToRefs(importTransactionStore);

    const matches = computed(() => {
      const matchesArray = importTransaction.value?.matches ?? [];
      matchesArray.map(match => match.selected = false);
      const selectedMatch = matchesArray.find(match => match.transaction.id === importTransaction.value.matchTransactionId);
      if (selectedMatch) {
        selectedMatch.selected = true;
      }
      return matchesArray;
    });

    const handleHide = () => {
      if (!importTransaction.value.matchTransactionId) {
        importTransaction.value.action = IMPORT_ACTION_IMPORT;
      }
    };

    return {
      t,
      importTransaction,
      matches,
      handleHide,
      MATCH_TRANSACTION_SELECTOR_MODAL_ID,
    };
  },
};
</script>
