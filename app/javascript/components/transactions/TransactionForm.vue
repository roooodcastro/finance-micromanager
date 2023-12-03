<template>
  <RailsForm
    :id="TRANSACTION_FORM_ID"
    method="POST"
    resource="transaction"
    @submit.prevent="handleSubmit"
  >
    <template v-slot:default="{ formHelper }">
      <FormInput
        v-model="transaction.name"
        field-name="name"
        :form-helper="formHelper"
        :value="transaction.name"
        :label="t('name_label')"
        required
      />

      <label
        :for="formHelper.fieldId('amount')"
        class="form-label"
      >
        {{ t('amount_label') }}
      </label>

      <RadioButtonsInput
        v-model="transaction.amountType"
        field-name="amount_type"
        :form-helper="formHelper"
        :label="t('amount_type_label')"
        :options="amountTypeOptions"
      />

      <div class="input-group mb-3">
        <span class="input-group-text">
          {{ currencySymbol }}
        </span>

        <input
          :id="formHelper.fieldId('amount')"
          :name="formHelper.fieldName('amount')"
          v-model="transaction.amount"
          type="number"
          class="form-control"
          step="0.01"
          required
        />
      </div>

      <FormInput
        v-model="transaction.transactionDate"
        field-name="transaction_date"
        :form-helper="formHelper"
        :label="t('date_label')"
        type="date"
        required
      />

      <label
        :for="formHelper.fieldId('category_id')"
        class="form-label"
      >
        {{ t('category_label') }}
      </label>

      <CategoriesSelect
        :id="formHelper.fieldId('category_id')"
        :name="formHelper.fieldName('category_id')"
        v-model="transaction.categoryId"
        :categories="categories"
        required
      />
    </template>
  </RailsForm>
</template>

<script>
import { computed, onMounted, onUpdated, ref } from 'vue';
import { storeToRefs } from 'pinia';
import _ from 'lodash';

import { transactions } from '~/api';
import I18n from '~/utils/I18n';
import useWalletStore from '~/stores/WalletStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import { parseLocaleNumber } from '~/utils/NumberFormatter.js';
import { TRANSACTION_FORM_ID } from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import RadioButtonsInput from '~/components/rails/RadioButtonsInput.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';

export default {
  components: {
    CategoriesSelect,
    FormInput,
    RadioButtonsInput,
    RailsForm,
  },

  emits: ['close'],

  setup(_props, { emit }) {
    const t = I18n.scopedTranslator('views.transactions.form');

    const walletStore = useWalletStore();
    const categoryStore = useCategoryStore();
    const transactionStore = useTransactionStore();

    const { currentWallet } = storeToRefs(walletStore);
    const { categories } = storeToRefs(categoryStore);
    const { transactionForFormModal: transaction } = storeToRefs(transactionStore);

    if (!categories.value.length) {
      categoryStore.fetchCategories({ items: Number.MAX_SAFE_INTEGER });
    }

    const amountTypeOptions = ref([]);
    const isNewRecord = computed(() => !transaction.value.id);
    const currencySymbol = computed(() => currentWallet.value.currencyObject.symbol);

    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewRecord.value
        ? transactions.create.path()
        : transactions.update.path({ id: transaction.value.id });
    });

    const updateTransactionDataWithDefaultValues = () => {
      if (transaction.value.amount) {
        transaction.value.amount = Math.abs(parseLocaleNumber(transaction.value.amount)).toFixed(2);
      }

      transaction.value.amountType = transaction.value.amountCents > 0 ? 'credit' : 'debit';
      amountTypeOptions.value = [
        { value: 'debit', label: t('debit_label'), checked: transaction.value.amountType === 'debit' },
        { value: 'credit', label: t('credit_label'), checked: transaction.value.amountType === 'credit' },
      ];

      const defaultTransactionDate = new Date().toISOString().split('T')[0];
      transaction.value.transactionDate = transaction.value.transactionDate || defaultTransactionDate;
    };

    onUpdated(updateTransactionDataWithDefaultValues);
    onMounted(updateTransactionDataWithDefaultValues);

    const handleSubmit = () => {
      const transactionFields = ['name', 'amount', 'transactionDate', 'amountType', 'categoryId'];
      const transactionData = _.pick(transaction.value, transactionFields);
      if (isNewRecord.value) {
        transactionStore
          .create(transactionData)
          .then(() => emit('close'));
      } else {
        transactionStore
          .update(transaction.value.id, transactionData)
          .then(() => emit('close'));
      }
    }

    return {
      t,
      amountTypeOptions,
      currencySymbol,
      formMethod,
      formAction,
      transaction,
      categories,
      handleSubmit,
      TRANSACTION_FORM_ID,
    };
  },
};
</script>
