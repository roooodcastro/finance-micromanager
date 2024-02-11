<template>
  <div class="border border-secondary rounded d-flex align-items-center">
    <span
      class="mx-3 my-2"
      :class="{ 'text-muted text-decoration-line-through': disabled }"
    >
      {{ condition.column ? t(`${condition.column}_label`) : '?' }}
      {{ condition.operator ? t(`${condition.operator}_operator_label`) : '?' }}
      {{ displayValue ? `"${displayValue}"` : '?' }}
    </span>

    <a
      v-if="editable"
      href="#"
      class="btn btn-sm btn-secondary rounded-0 align-self-stretch d-flex align-items-center"
      @click="handleRemove"
    >
      <FontAwesomeIcon icon="xmark" />
    </a>
  </div>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';
import { RulesParser } from '~/lib/transaction_predictions/RulesParser.js';

export default {
  components: {
    FontAwesomeIcon,
  },
  props: {
    conditionIndex: {
      type: Number,
      required: true,
    },
    editable: {
      type: Boolean,
      default: false,
    },
    disabled: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_predictions.form');

    const transactionPredictionStore = useTransactionPredictionStore();
    const { transactionPrediction } = storeToRefs(transactionPredictionStore);

    const rulesParser = computed(() => new RulesParser(transactionPrediction.value.rulesJson));
    const condition = computed(() => rulesParser.value.getConditionAt(props.conditionIndex));
    const displayValue = computed(() => rulesParser.value.formattedValueFor(condition.value));

    const handleRemove = () => {
      rulesParser.value.deleteConditionAt(props.conditionIndex);
      transactionPrediction.value.rulesJson = rulesParser.value.toJson();
    }

    return {
      t,
      condition,
      displayValue,
      handleRemove,
    };
  }
};
</script>
