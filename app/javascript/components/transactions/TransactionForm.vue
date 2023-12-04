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

      <div class="d-flex">
        <div class="input-group mb-3">
          <span class="input-group-text">
            {{ currencySymbol }}
          </span>

          <input
            :id="formHelper.fieldId('amount')"
            v-model="transaction.amount"
            :name="formHelper.fieldName('amount')"
            type="number"
            class="form-control"
            step="0.01"
            required
          />
        </div>

        <ToggleSwitch
          v-model="transaction.amountType"
          field-name="amount_type"
          :form-helper="formHelper"
          class="ms-2"
          input-off-classes="text-danger-emphasis bg-danger-subtle border-danger-subtle"
          input-on-classes="text-success-emphasis bg-success-subtle border-success-subtle"
          :off-label="t('debit_label')"
          :on-label="t('credit_label')"
          :off-value="'debit'"
          :on-value="'credit'"
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
        v-model="transaction.categoryId"
        :name="formHelper.fieldName('category_id')"
        required
      />
    </template>
  </RailsForm>
</template>

<script>
import { computed, onMounted, watch } from 'vue';
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
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import ToggleSwitch from '@/components/ui/ToggleSwitch.vue';

export default {
  components: {
    ToggleSwitch,
    CategoriesSelect,
    FormInput,
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

      transaction.value.amountType =  transaction.value.amountCents > 0 ? 'credit' : 'debit';

      const defaultTransactionDate = new Date().toISOString().split('T')[0];
      transaction.value.transactionDate = transaction.value.transactionDate || defaultTransactionDate;
    };

    watch(
      () => transaction.value,
      updateTransactionDataWithDefaultValues,
    );

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
      currencySymbol,
      formMethod,
      formAction,
      transaction,
      handleSubmit,
      TRANSACTION_FORM_ID,
    };
  },
};
</script>
