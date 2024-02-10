<template>
  <div
    :id="TRANSACTION_PREDICTION_CONDITION_MODAL_ID"
    class="modal modal-lg"
    tabindex="-1"
    v-on="{ 'show.bs.modal': handleShow }"
  >
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ t('sub_header_edit_condition') }}
          </h5>
        </div>
        <div class="modal-body">
          <form @submit.prevent="handleSave">
            <div class="row gap-2 gap-lg-0">
              <div class="col-12 col-lg-4">
                <FormSelect
                  v-model="condition.column"
                  field-name="condition_column"
                  :options="columnSelectOptions"
                  required
                  @change="handleConditionColumnChange"
                />
              </div>

              <div class="col-12 col-lg-4">
                <FormSelect
                  v-model="condition.operator"
                  field-name="condition_operator"
                  :options="operatorSelectOptions"
                  required
                />
              </div>

              <div class="col-12 col-lg-4">
                <CategoriesSelect
                  v-if="condition.column === 'category_id'"
                  v-model="condition.value"
                  :placeholder="t('label_condition_category')"
                  required
                />

                <WalletsSelect
                  v-else-if="condition.column === 'wallet_id'"
                  v-model="condition.value"
                  :placeholder="t('label_condition_wallet')"
                  required
                />

                <input
                  v-else
                  v-model="condition.value"
                  :type="inputTypeFor(condition.column)"
                  :placeholder="t('value_label')"
                  class="form-control"
                  required
                >
              </div>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button
            type="button"
            class="btn btn-outline-secondary"
            data-bs-dismiss="modal"
          >
            {{ t('cancel') }}
          </button>
          <button
            type="button"
            class="btn btn-primary"
            @click="handleSave"
          >
            {{ t('submit') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { TRANSACTION_PREDICTION_CONDITION_MODAL_ID } from '~/utils/Constants.js';
import { CONTAINS_OPERATOR, EQUALS_OPERATOR, RulesParser } from '~/lib/transaction_predictions/RulesParser.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';
import useModalStore from '~/stores/ModalStore.js';

import FormSelect from '~/components/forms/FormSelect.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';

export default {
  components: {
    CategoriesSelect,
    FormSelect,
    WalletsSelect,
  },

  setup() {
    const t = I18n.scopedTranslator('views.transaction_predictions.form');

    const operatorSelectOptions = [
      { label: t('select_placeholder_label'), value: '' },
      { label: t('contains_operator_label'), value: CONTAINS_OPERATOR },
      { label: t('equals_operator_label'), value: EQUALS_OPERATOR },
    ];

    const columnSelectOptions = [
      { label: t('select_placeholder_label'), value: '' },
      { label: t('transaction_name_label'), value: 'transaction_name' },
      { label: t('transaction_date_label'), value: 'transaction_date' },
      { label: t('amount_label'), value: 'amount' },
      { label: t('category_id_label'), value: 'category_id' },
      { label: t('wallet_id_label'), value: 'wallet_id' },
    ];

    const modalStore = useModalStore();
    const transactionPredictionStore = useTransactionPredictionStore();
    const { transactionPrediction, currentConditionIndex } = storeToRefs(transactionPredictionStore);

    const condition = ref({});

    const inputTypeFor = (column) => {
      if (column === 'transaction_date') {
        return 'date';
      } else if (column === 'amount') {
        return 'number';
      } else {
        return 'text';
      }
    };

    const handleConditionColumnChange = () => {
      condition.value.value = '';

      if (condition.value.column === 'transaction_name') {
        condition.value.operator = CONTAINS_OPERATOR;
      } else {
        condition.value.operator = EQUALS_OPERATOR;
      }
    };

    const handleShow = () => {
      condition.value = new RulesParser(transactionPrediction.value.rulesJson)
        .getConditionAt(currentConditionIndex.value);

      if (!condition.value.operator) {
        condition.value.operator = EQUALS_OPERATOR;
      }
    };

    const handleSave = () => {
      if (condition.value.column && condition.value.operator && condition.value.value) {
        const rulesParser = new RulesParser(transactionPrediction.value.rulesJson);
        rulesParser.setConditionAt(currentConditionIndex.value, condition.value);
        transactionPrediction.value.rulesJson = rulesParser.toJson();

        modalStore.hide(TRANSACTION_PREDICTION_CONDITION_MODAL_ID);
      } else {
        document.querySelector(`#${TRANSACTION_PREDICTION_CONDITION_MODAL_ID} form`).reportValidity();
      }
    };

    return {
      t,
      condition,
      operatorSelectOptions,
      columnSelectOptions,
      inputTypeFor,
      handleShow,
      handleSave,
      handleConditionColumnChange,
      TRANSACTION_PREDICTION_CONDITION_MODAL_ID,
    };
  },
};
</script>
