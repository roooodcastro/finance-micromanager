<template>
  <div class="border border-secondary rounded d-flex align-items-center">
    <span
      class="mx-3 my-2"
      :class="{ 'text-muted text-decoration-line-through': disabled }"
    >
      {{ action.column ? t(`${action.column}_label`) : '?' }}
      {{ t('label_with') }}
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
    actionIndex: {
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
    const action = computed(() => rulesParser.value.getActionAt(props.actionIndex));
    const displayValue = computed(() => rulesParser.value.formattedValueFor(action.value));

    const handleRemove = () => {
      rulesParser.value.deleteActionAt(props.actionIndex);
      transactionPrediction.value.rulesJson = rulesParser.value.toJson();
    }

    return {
      t,
      action,
      displayValue,
      handleRemove,
    };
  }
};
</script>
