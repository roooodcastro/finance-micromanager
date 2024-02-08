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

      <div class="card card-body pb-0">
        <div class="row gap-3 gap-lg-0">
          <div class="col-12 col-lg-4 col-xl-5">
            <FormSelect
              v-model="condition.column"
              field-name="condition_column"
              :form-helper="formHelper"
              :options="columnSelectOptions"
              required
              @change="handleConditionColumnChange"
            />
          </div>

          <div class="col-12 col-lg-4 col-xl-2">
            <FormSelect
              v-model="condition.operator"
              field-name="condition_operator"
              :form-helper="formHelper"
              :options="operatorSelectOptions"
              class="mb-0 mb-lg-3"
              required
            />
          </div>

          <div class="col-12 col-lg-4 col-xl-5">
            <CategoriesSelect
              v-if="condition.column === 'category_id'"
              :id="formHelper.fieldId('value_label')"
              v-model="condition.value"
              :name="formHelper.fieldName('condition_value')"
              :placeholder="t('label_condition_category')"
              class="mb-0 mb-lg-3"
              required
            />

            <WalletsSelect
              v-else-if="condition.column === 'wallet_id'"
              :id="formHelper.fieldId('value_label')"
              v-model="condition.value"
              :name="formHelper.fieldName('condition_value')"
              :placeholder="t('label_condition_wallet')"
              class="mb-0 mb-lg-3"
              required
            />

            <FormInput
              v-else
              v-model="condition.value"
              field-name="condition_value"
              :form-helper="formHelper"
              :type="inputTypeFor(condition.column)"
              :placeholder="t('value_label')"
              required
            />
          </div>
        </div>
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
</template>

<script>
import { computed, onMounted, ref, toRef } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
// import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import useTransactionPredictionsStore from '~/stores/TransactionPredictionStore.js';
import { TRANSACTION_PREDICTION_FORM_ID } from '~/utils/Constants.js';
import { CONTAINS_OPERATOR, EQUALS_OPERATOR } from '~/lib/transaction_predictions/RulesParser.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import FormSelect from '~/components/forms/FormSelect.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';

export default {
  components: {
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
    const condition = ref({});
    const action = ref({});
    const transactionPredictionRef = toRef(props, 'transactionPrediction');

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

    const transactionPredictionStore = useTransactionPredictionsStore();
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

    const updateDataWithDefaultValues = () => {
      if (isNewRecord.value) {
        condition.value.operator = EQUALS_OPERATOR;
      }
    };

    const handleConditionColumnChange = () => {
      condition.value.value = '';
    }

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
      condition,
      loading,
      formTitle,
      formMethod,
      formAction,
      transactionPredictionRef,
      operatorSelectOptions,
      columnSelectOptions,
      inputTypeFor,
      handleConditionColumnChange,
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
