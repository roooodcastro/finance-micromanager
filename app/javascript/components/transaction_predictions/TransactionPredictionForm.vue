<template>
  <RailsForm
    :id="TRANSACTION_PREDICTION_FORM_ID"
    :action="formAction"
    :method="formMethod"
    resource="transactionPrediction"
    @submit.prevent="handleSubmit"
  >
    <template v-slot:default="{ formHelper }">
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
    </template>
  </RailsForm>

  <TransactionPredictionConditionModal />
  <TransactionPredictionActionModal />
</template>

<script>
import { computed, ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
// import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
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

    const loading = ref(false);

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
      return '';
      // return isNewRecord.value
      //   ? transactionPredictionsApi.create.path()
      //   : transactionPredictionsApi.update.path({ id: transactionPredictionFromStore.value.id });
    });

    const handleSubmit = () => {
      loading.value = true;

      if (isNewRecord.value) {
        transactionPredictionStore
          .create(transactionPredictionFromStore.value)
          .then(() => {})
          .catch(() => {})
          .finally(() => loading.value = false);
      } else {
        transactionPredictionStore
          .update(transactionPredictionFromStore.value.id, transactionPredictionFromStore.value)
          .then(() => {})
          .catch(() => {})
          .finally(() => loading.value = false);
      }
    };

    return {
      t,
      loading,
      formTitle,
      formMethod,
      formAction,
      transactionPredictionFromStore,
      handleSubmit,
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
