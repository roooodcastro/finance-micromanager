<template>
  <ListItemDrawerContextMenu class="list-group-item p-0 overflow-hidden">
    <template v-slot:actions>
      <TransactionPredictionActions
        :transaction-prediction="transactionPrediction"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div class="d-flex align-items-center bg-light-subtle">
        <a
          class="text-decoration-none text-body list-group-item-action d-flex align-items-center p-2 ps-4 min-width-0 side-strip"
          :class="{ 'side-strip-danger': isDisabled, 'side-strip-primary': !isDisabled }"
          :href="showPath"
        >
          <div class="flex-grow-1">
            <div class="d-flex justify-content-between">
              <span class="d-flex align-items-center">
                <span :class="{ 'text-muted': isDisabled }">
                  {{ transactionPrediction.name }}
                </span>
                <span
                  v-if="isDisabled"
                  class="badge text-bg-danger ms-2"
                >
                  {{ t('disabled') }}
                </span>
              </span>
            </div>
          </div>
        </a>

        <div class="d-none d-lg-flex ms-auto pe-2 flex-shrink-0">
          <TransactionPredictionActions :transaction-prediction="transactionPrediction" />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';

import TransactionPredictionActions from '~/components/transaction_predictions/TransactionPredictionActions.vue';
import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';

export default {
  components: {
    ListItemDrawerContextMenu,
    TransactionPredictionActions,
  },

  props: {
    transactionPrediction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_predictions.list');

    const showPath = transactionPredictionsApi.show.path({ id: props.transactionPrediction.id });
    const isDisabled = computed(() => !!props.transactionPrediction.disabledAt);
    const isDebit = computed(() => props.transactionPrediction.transactionAmount < 0);
    const isCredit = computed(() => props.transactionPrediction.transactionAmount > 0);
    const isCustomRule = computed(() => props.transactionPrediction.scheduleType === 'C');

    return {
      I18n,
      t,
      showPath,
      isDisabled,
      isDebit,
      isCredit,
      isCustomRule,
      formatDate,
      formatMoney,
    };
  }
};
</script>
