<template>
  <ListItem :record="transaction">
    <RailsForm
      resource="transaction"
    >
      <template v-slot:default="{ formHelper }">
        <div class="d-flex align-items-center p-2">
          <FormInput
            v-model="transaction.name"
            :form-helper="formHelper"
            label="Name"
            :field-name="name"
            no-margin
          />

          <div>
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
                  :disabled="transaction.lockedByReconciliation"
                  required
                  @input="handleInput"
                >
              </div>

              <ToggleSwitch
                v-model="transaction.amountType"
                field-name="amount_type"
                :form-helper="formHelper"
                class="ms-2"
                input-off-classes="text-danger-emphasis bg-danger-subtle border-danger-subtle"
                input-on-classes="text-success-emphasis bg-success-subtle border-success-subtle"
                :off-label="t('spends_label')"
                :on-label="t('income_label')"
                :off-value="'debit'"
                :on-value="'credit'"
                :disabled="transaction.lockedByReconciliation"
              />
            </div>
          </div>

          <FormInput
            v-model="transaction.transactionDate"
            :form-helper="formHelper"
            label="Date"
            :field-name="transaction_date"
            type="date"
            no-margin
          />
        </div>
      </template>
    </RailsForm>
  </ListItem>
</template>

<script>
import I18n from '~/utils/I18n.js';

import ListItem from '~/components/ui/ListItem.vue';
import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '@/components/rails/FormInput.vue';
import ToggleSwitch from '@/components/ui/ToggleSwitch.vue';

export default {
  components: {
    ToggleSwitch,
    FormInput,
    ListItem,
    RailsForm,
  },

  props: {
    transaction: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.preview');

    return {
      t,
    };
  },
};
</script>
