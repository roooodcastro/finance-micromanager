<template>
  <div class="GridRow__left">
    <div class="d-flex gap-2 align-items-center">
      <span :class="{ 'text-muted': isDisabled }">
        {{ transactionPrediction.name }}
      </span>
      <span
        v-if="isDisabled"
        class="badge text-bg-danger ms-2"
      >
        {{ t('disabled') }}
      </span>
    </div>
    <div>
      {{ rulesParser.conditionsDescription }}
    </div>
    <div>
      {{ rulesParser.actionsDescription }}
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import { RulesParser } from '~/lib/transaction_predictions/RulesParser.js';

export default {
  props: {
    transactionPrediction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_predictions.list');

    const rulesParser = computed(() => new RulesParser(props.transactionPrediction.rulesJson));
    const isDisabled = computed(() => !!props.transactionPrediction.disabledAt);

    return {
      I18n,
      t,
      isDisabled,
      rulesParser,
    };
  }
};
</script>
