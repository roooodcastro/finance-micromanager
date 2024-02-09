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
        v-model="transactionPredictionRef.name"
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

      <div class="card card-body pb-0">
        <div class="row gap-3 gap-lg-0">
          <div class="col-12 col-lg-6">
            <FormSelect
              v-model="action.column"
              field-name="action_column"
              :form-helper="formHelper"
              :options="columnSelectOptions"
              class="mb-0 mb-lg-3"
              required
            />
          </div>

          <div class="col-12 col-lg-6">
            <CategoriesSelect
              v-if="action.column === 'category_id'"
              :id="formHelper.fieldId('value_label')"
              v-model="action.value"
              :name="formHelper.fieldName('action_value')"
              :placeholder="t('label_action_category')"
              required
            />

            <WalletsSelect
              v-else-if="action.column === 'wallet_id'"
              :id="formHelper.fieldId('value_label')"
              v-model="action.value"
              :name="formHelper.fieldName('action_value')"
              :placeholder="t('label_action_wallet')"
              required
            />

            <FormInput
              v-else
              v-model="action.value"
              field-name="action_value"
              :form-helper="formHelper"
              :type="inputTypeFor(action.column)"
              :placeholder="t('label_with')"
              required
            />
          </div>
        </div>
      </div>
    </template>
  </RailsForm>

  <TransactionPredictionConditionModal />
</template>

<script>
import { computed, onMounted, ref, toRef } from 'vue';
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
import FormSelect from '~/components/forms/FormSelect.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';
import TransactionPredictionConditionModal from '~/components/transaction_predictions/TransactionPredictionConditionModal.vue';
import TransactionPredictionCondition from '~/components/transaction_predictions/TransactionPredictionCondition.vue';

export default {
  components: {
    TransactionPredictionCondition,
    TransactionPredictionConditionModal,
    WalletsSelect,
    CategoriesSelect,
    FormSelect,
    FormInput,
    RailsForm,
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
    const action = ref({});
    const transactionPredictionRef = toRef(props, 'transactionPrediction');

    const columnSelectOptions = [
      { label: t('select_placeholder_label'), value: '' },
      { label: t('transaction_name_label'), value: 'transaction_name' },
      { label: t('transaction_date_label'), value: 'transaction_date' },
      { label: t('amount_label'), value: 'amount' },
      { label: t('category_id_label'), value: 'category_id' },
      { label: t('wallet_id_label'), value: 'wallet_id' },
    ];

    const transactionPredictionStore = useTransactionPredictionsStore();
    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();

    const { categories } = storeToRefs(categoryStore);
    const { activeWallets } = storeToRefs(walletStore);
    const {
      transactionPrediction: transactionPredictionFromStore,
    } = storeToRefs(transactionPredictionStore);

    transactionPredictionFromStore.value = props.transactionPrediction;

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    if (!activeWallets.value.length) {
      walletStore.fetchCollection();
    }

    const isNewRecord = computed(() => !transactionPredictionRef.value.id);

    const inputTypeFor = (column) => {
      if (column === 'transaction_date') {
        return 'date';
      } else if (column === 'amount') {
        return 'number';
      } else {
        return 'text';
      }
    };

    const formTitle = computed(() => isNewRecord.value ? t('new_title') : t('edit_title'));
    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return '';
      // return isNewRecord.value
      //   ? transactionPredictionsApi.create.path()
      //   : transactionPredictionsApi.update.path({ id: transactionPredictionRef.value.id });
    });

    onMounted(() => {
      updateDataWithDefaultValues();
    });

    const updateDataWithDefaultValues = () => {};

    const handleSubmit = () => {
      loading.value = true;

      if (isNewRecord.value) {
        transactionPredictionStore
          .create(transactionPredictionRef.value)
          .then(() => {})
          .catch(() => {})
          .finally(() => loading.value = false);
      } else {
        transactionPredictionStore
          .update(transactionPredictionRef.value.id, transactionPredictionRef.value)
          .then(() => {})
          .catch(() => {})
          .finally(() => loading.value = false);
      }
    };

    return {
      t,
      action,
      loading,
      formTitle,
      formMethod,
      formAction,
      transactionPredictionRef,
      columnSelectOptions,
      inputTypeFor,
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
