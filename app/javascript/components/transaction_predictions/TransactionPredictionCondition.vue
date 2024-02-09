<template>
  <div class="border border-secondary rounded d-flex align-items-center">
    <span class="mx-3 my-2">
      {{ condition.column ? t(`${condition.column}_label`) : '?' }}
      {{ condition.operator ? t(`${condition.operator}_operator_label`) : '?' }}
      {{ condition.value ? `"${condition.value}"` : '?' }}
    </span>

    <a
      href="#"
      class="btn btn-sm btn-secondary rounded-0 align-self-stretch d-flex align-items-center"
      @click="handleEdit"
    >
      <FontAwesomeIcon icon="pen-to-square" />
    </a>
  </div>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import useModalStore from '~/stores/ModalStore.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';
import { TRANSACTION_PREDICTION_CONDITION_MODAL_ID } from '~/utils/Constants.js';
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
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_predictions.form');

    const modalStore = useModalStore();
    const transactionPredictionStore = useTransactionPredictionStore();
    const { transactionPrediction, currentConditionIndex } = storeToRefs(transactionPredictionStore);

    const condition = computed(() => {
      return new RulesParser(transactionPrediction.value.rulesJson).getConditionAt(props.conditionIndex);
    });

    const handleEdit = () => {
      currentConditionIndex.value = props.conditionIndex;
      modalStore.show(TRANSACTION_PREDICTION_CONDITION_MODAL_ID);
    }

    return {
      t,
      condition,
      handleEdit,
    };
  }
};
</script>
