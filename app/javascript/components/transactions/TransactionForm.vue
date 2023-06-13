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
            :value="transaction.name"
            :label="t('name_label')"
            required
          />

          <FormInput
            field-name="amount"
            :form-helper="formHelper"
            :value="transaction.amount"
            :label="t('amount_label')"
            :prepend="currencySymbol"
            type="number"
            step="0.01"
            required
          />

          <FormInput
            field-name="transaction_date"
            :form-helper="formHelper"
            :value="transactionDate"
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
            :value="transaction.category_id"
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
import { transactions } from '~/api';
import I18n from '~/utils/I18n';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';

export default {
  components: {
    CategoriesSelect,
    FormInput,
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
    const listTransactionsPath = transactions.list.path();
    const isNewTransaction = !props.transaction.id;
    const currencySymbol = '€'; // TODO: set correct currency symbol for account currency

    const formMethod = isNewTransaction ? 'POST' : 'PATCH';
    const formAction = isNewTransaction
      ? transactions.create.path()
      : transactions.update.path({ id: props.transaction.id });

    const formTitle = isNewTransaction ? t('new_title') : t('edit_title', { transaction: props.transaction.name });
    const defaultTransactionDate = new Date().toISOString().split('T')[0];
    const transactionDate = props.transaction.transaction_date || defaultTransactionDate;

    return {
      currencySymbol,
      listTransactionsPath,
      formMethod,
      formAction,
      formTitle,
      transactionDate,
      t,
    };
  },
};
</script>
