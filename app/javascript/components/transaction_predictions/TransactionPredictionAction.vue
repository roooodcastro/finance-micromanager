<template>
  <div class="border border-secondary rounded d-flex align-items-center">
    <span class="mx-3 my-2">
      {{ action.column ? t(`${action.column}_label`) : '?' }}
      {{ t('label_with') }}
      {{ displayValue ? `"${displayValue}"` : '?' }}
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
import { TRANSACTION_PREDICTION_ACTION_MODAL_ID } from '~/utils/Constants.js';
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
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_predictions.form');

    const modalStore = useModalStore();
    const transactionPredictionStore = useTransactionPredictionStore();
    const { transactionPrediction, currentActionIndex } = storeToRefs(transactionPredictionStore);

    const rulesParser = computed(() => new RulesParser(transactionPrediction.value.rulesJson));
    const action = computed(() => rulesParser.value.getActionAt(props.actionIndex));
    const displayValue = computed(() => rulesParser.value.formattedValueFor(action.value));

    const handleEdit = () => {
      currentActionIndex.value = props.actionIndex;
      modalStore.show(TRANSACTION_PREDICTION_ACTION_MODAL_ID);
    }

    return {
      t,
      action,
      displayValue,
      handleEdit,
    };
  }
};
</script>
