<template>
  <RailsForm
    :id="TRANSACTION_PREDICTION_FORM_ID"
    :action="formAction"
    :method="formMethod"
    resource="transaction_prediction"
  >
    <template v-slot:default="{ formHelper }">
      <input
        v-model="transactionPredictionFromStore.rulesJson"
        :id="formHelper.fieldId('rules_json')"
        :name="formHelper.fieldName('rules_json')"
        type="hidden"
      >

      <FormInput
        v-model="transactionPredictionFromStore.name"
        field-name="name"
        :form-helper="formHelper"
        :label="t('name_label')"
        required
      />

      <h5 class="my-3">
        {{ t('sub_header_conditions') }}
      </h5>


      <div class="card card-body flex-row align-items-center flex-wrap gap-2">
        <TransactionPredictionCondition :condition-index="0" />
      </div>

      <h5 class="my-3">
        {{ t('sub_header_action') }}
      </h5>

      <div class="card card-body flex-row align-items-center flex-wrap gap-2">
        <TransactionPredictionAction :action-index="0" />
      </div>

      <hr>

      <div class="d-grid d-md-block">
        <button
          type="submit"
          class="btn btn-primary"
        >
          <FontAwesomeIcon
            icon="floppy-disk"
            class="me-lg-2"
          />

          {{ t('submit') }}
        </button>
      </div>
    </template>
  </RailsForm>

  <TransactionPredictionConditionModal />
  <TransactionPredictionActionModal />
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import useTransactionPredictionsStore from '~/stores/TransactionPredictionStore.js';
import {
  TRANSACTION_PREDICTION_FORM_ID,
} from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import TransactionPredictionConditionModal from '~/components/transaction_predictions/TransactionPredictionConditionModal.vue';
import TransactionPredictionCondition from '~/components/transaction_predictions/TransactionPredictionCondition.vue';
import TransactionPredictionAction from '~/components/transaction_predictions/TransactionPredictionAction.vue';
import TransactionPredictionActionModal from '~/components/transaction_predictions/TransactionPredictionActionModal.vue';

export default {
  components: {
    FontAwesomeIcon,
    FormInput,
    RailsForm,
    TransactionPredictionAction,
    TransactionPredictionActionModal,
    TransactionPredictionCondition,
    TransactionPredictionConditionModal,
  },

  props: {
    transactionPrediction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_predictions.form');

    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();
    const transactionPredictionStore = useTransactionPredictionsStore();

    const { categories } = storeToRefs(categoryStore);
    const { activeWallets } = storeToRefs(walletStore);
    const { transactionPrediction: transactionPredictionFromStore } = storeToRefs(transactionPredictionStore);

    transactionPredictionFromStore.value = props.transactionPrediction;

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    if (!activeWallets.value.length) {
      walletStore.fetchCollection();
    }

    const isNewRecord = computed(() => !transactionPredictionFromStore.value.id);
    const formTitle = computed(() => isNewRecord.value ? t('new_title') : t('edit_title'));
    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewRecord.value
        ? transactionPredictionsApi.create.path()
        : transactionPredictionsApi.update.path({ id: transactionPredictionFromStore.value.id });
    });

    return {
      t,
      formTitle,
      formMethod,
      formAction,
      transactionPredictionFromStore,
      TRANSACTION_PREDICTION_FORM_ID,
    };
  },
};
</script>

<style lang="scss" scoped>
.TransactionPredictionForm__schedule-grid {
  grid-template-columns: repeat(2, 1fr);
}
</style>
