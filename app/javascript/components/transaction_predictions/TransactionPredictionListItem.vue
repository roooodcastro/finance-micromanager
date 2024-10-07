<template>
  <ListItem
    :record="transactionPrediction"
    :actions-component="TransactionPredictionActions"
  >
    <a
      class="text-decoration-none text-body list-group-item-action d-flex align-items-center p-2 ps-4 min-width-0 side-strip"
      :class="{ 'side-strip-danger': isDisabled, 'side-strip-primary': !isDisabled }"
      :href="showPath"
    >
      <div class="flex-grow-1 min-width-0">
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

        <div class="fs-6 mt-1 text-muted text-truncate">
          {{ t('label_when') }}
          {{ rulesParser.conditionsDescription }}
        </div>

        <div class="fs-6 mt-1 text-muted text-truncate">
          {{ t('label_then') }}
          {{ rulesParser.actionsDescription }}
        </div>
      </div>
    </a>
  </ListItem>
</template>

<script>
import { computed, markRaw } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import { RulesParser } from '~/lib/transaction_predictions/RulesParser.js';

import TransactionPredictionActions from '~/components/transaction_predictions/TransactionPredictionActions.vue';
import ListItem from '~/components/ui/ListItem.vue';

export default {
  components: { ListItem },

  props: {
    transactionPrediction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    markRaw(TransactionPredictionActions);
    const t = I18n.scopedTranslator('views.transaction_predictions.list');

    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();

    const { categories } = storeToRefs(categoryStore);
    const { activeWallets } = storeToRefs(walletStore);

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    if (!activeWallets.value.length) {
      walletStore.fetchCollection();
    }

    const rulesParser = computed(() => new RulesParser(props.transactionPrediction.rulesJson));

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
      rulesParser,
      TransactionPredictionActions,
    };
  }
};
</script>
