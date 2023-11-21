<template>
  <RailsForm
    :action="formAction"
    :method="formMethod"
    resource="transaction"
  >
    <template v-slot:default="{ formHelper }">
      <div class="card">
        <div class="card-body">
          <h4 class="card-title">
            {{ formTitle }}
          </h4>

          <hr />

          <FormInput
            field-name="name"
            :form-helper="formHelper"
            :value="transactionState.name"
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
            field-name="amount_type"
            :form-helper="formHelper"
            :value="transactionState.amount_type"
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
              type="number"
              class="form-control"
              :value="transactionState.amount"
              step="0.01"
              required
            />
          </div>

          <FormInput
            field-name="transaction_date"
            :form-helper="formHelper"
            :value="transactionState.transactionDate"
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
            :value="transactionState.categoryId"
            :categories="categories"
            required
          />
        </div>

        <div class="card-footer">
          <div class="d-grid gap-2 d-md-flex">
            <button
              type="submit"
              class="btn btn-primary flex-md-fill"
            >
              {{ t('submit') }}
            </button>

            <a
              :href="listTransactionsPath"
              class="btn btn-outline-secondary flex-md-fill"
            >
              {{ t('back') }}
            </a>
          </div>
        </div>
      </div>
    </template>
  </RailsForm>
</template>

<script>
import { ref } from 'vue';

import { transactions } from '~/api';
import I18n from '~/utils/I18n';
import useWalletStore from '~/stores/WalletStore.js';
import { parseLocaleNumber } from '~/utils/NumberFormatter.js';

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

  props: {
    transaction: {
      type: Object,
      required: true,
    },
    categories: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transactions.form');
    const listTransactionsPath = transactions.index.path();
    const isNewTransaction = !props.transaction.id;
    const walletStore = useWalletStore();
    const currencySymbol = walletStore.currentWallet.currencyObject.symbol;

    const formMethod = isNewTransaction ? 'POST' : 'PATCH';
    const formAction = isNewTransaction
      ? transactions.create.path()
      : transactions.update.path({ id: props.transaction.id });

    const formTitle = isNewTransaction ? t('new_title') : t('edit_title', { transaction: props.transaction.name });

    const transactionState = ref(props.transaction);

    const defaultTransactionDate = new Date().toISOString().split('T')[0];
    transactionState.value.transactionDate = transactionState.value.transactionDate || defaultTransactionDate;

    transactionState.value.amountType = transactionState.value.amountCents > 0 ? 'credit' : 'debit';

    if (transactionState.value.amount) {
      transactionState.value.amount = Math.abs(parseLocaleNumber(transactionState.value.amount)).toFixed(2);
    }

    const amountTypeOptions = [
      { value: 'debit', label: t('debit_label'), checked: transactionState.value.amountType === 'debit' },
      { value: 'credit', label: t('credit_label'), checked: transactionState.value.amountType === 'credit' },
    ];

    return {
      amountTypeOptions,
      currencySymbol,
      listTransactionsPath,
      formMethod,
      formAction,
      formTitle,
      transactionState,
      t,
    };
  },
};
</script>
