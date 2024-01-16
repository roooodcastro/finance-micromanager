<template>
  <FormModal
    :t="t"
    :record="transactionAutomation"
    :form-id="TRANSACTION_AUTOMATION_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
    @show="updateDataWithDefaultValues"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="TRANSACTION_AUTOMATION_FORM_ID"
        :action="formAction"
        :method="formMethod"
        resource="transactionAutomation"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <h6 class="my-3">
            {{ t('sub_header_schedule') }}
          </h6>

          <label
            :for="formHelper.fieldId('schedule_interval')"
            class="form-label"
          >
            {{ t('schedule_type_interval_label') }}
          </label>

          <div class="TransactionAutomationForm__schedule-grid d-grid gap-2">
            <FormInput
              v-model="transactionAutomation.scheduleInterval"
              field-name="schedule_interval"
              :form-helper="formHelper"
              type="number"
              class="flex-grow-1"
              min="1"
              required
            />

            <FormSelect
              v-model="transactionAutomation.scheduleType"
              :options="scheduleTypeOptions"
              field-name="schedule_type"
              :form-helper="formHelper"
              class="flex-grow-1"
              required
            />
          </div>

          <FormInput
            v-model="transactionAutomation.nextScheduleDate"
            field-name="next_schedule_date"
            :form-helper="formHelper"
            :label="t('next_schedule_date_label')"
            type="date"
            required
          />

          <hr>

          <h6 class="mt-4 mb-3">
            {{ t('sub_header_transaction') }}
          </h6>

          <FormInput
            v-model="transactionAutomation.transactionName"
            field-name="transaction_name"
            :form-helper="formHelper"
            :label="t('transaction_name_label')"
            required
          />

          <label
            :for="formHelper.fieldId('amount')"
            class="form-label"
          >
            {{ t('transaction_amount_label') }}
          </label>

          <div class="d-flex">
            <div class="input-group mb-3">
              <span class="input-group-text">
                {{ currencySymbol }}
              </span>

              <input
                :id="formHelper.fieldId('transaction_amount')"
                v-model="transactionAutomation.transactionAmount"
                :name="formHelper.fieldName('transaction_amount')"
                type="number"
                class="form-control"
                step="0.01"
                required
              >
            </div>

            <ToggleSwitch
              v-model="transactionAutomation.amountType"
              field-name="amount_type"
              :form-helper="formHelper"
              class="ms-2"
              input-off-classes="text-danger-emphasis bg-danger-subtle border-danger-subtle"
              input-on-classes="text-success-emphasis bg-success-subtle border-success-subtle"
              :off-label="t('debit_label')"
              :on-label="t('credit_label')"
              off-value="debit"
              on-value="credit"
            />
          </div>

          <label
            :for="formHelper.fieldId('transaction_category_id')"
            class="form-label"
          >
            {{ t('transaction_category_label') }}
          </label>

          <CategoriesSelect
            :id="formHelper.fieldId('transaction_category_id')"
            v-model="transactionAutomation.transactionCategoryId"
            :name="formHelper.fieldName('transaction_category_id')"
            required
          />

          <label
            :for="formHelper.fieldId('transaction_wallet_id')"
            class="form-label mt-3"
          >
            {{ t('transaction_wallet_label') }}
            <span class="fst-italic">({{ t('optional') }})</span>
          </label>

          <WalletsSelect
            :id="formHelper.fieldId('transaction_wallet_id')"
            v-model="transactionAutomation.transactionWalletId"
            :name="formHelper.fieldName('transaction_wallet_id')"
          />
        </template>
      </RailsForm>
    </template>
  </FormModal>
</template>

<script>
import { computed, onMounted, ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { transactionAutomations as transactionAutomationsApi } from '~/api/all.js';
import useTransactionAutomationsStore from '~/stores/TransactionAutomationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import { TRANSACTION_AUTOMATION_FORM_ID } from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import FormSelect from '~/components/forms/FormSelect.vue';
import FormModal from '~/components/forms/FormModal.vue';
import ToggleSwitch from '~/components/ui/ToggleSwitch.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';

export default {
  components: {
    WalletsSelect, CategoriesSelect,
    ToggleSwitch,
    FormInput,
    FormModal,
    FormSelect,
    RailsForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.transaction_automations.form');

    const loading = ref(false);

    const scheduleTypeOptions = [
      { value: 'M', label: t('schedule_type_month') },
      { value: 'W', label: t('schedule_type_week') },
      { value: 'D', label: t('schedule_type_day') },
    ];

    const modalStore = useModalStore();
    const profileStore = useProfileStore();

    const modalId = modalStore.modalId(TRANSACTION_AUTOMATION_FORM_ID);

    const { currentProfile } = storeToRefs(profileStore);
    const currencySymbol = computed(() => currentProfile.value.currencyObject.symbol);

    const transactionAutomationStore = useTransactionAutomationsStore();
    const {
      transactionAutomationForFormModal: transactionAutomation,
      actionName,
    } = storeToRefs(transactionAutomationStore);

    const isNewRecord = computed(() => !transactionAutomation.value.id);

    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewRecord.value
        ? transactionAutomationsApi.create.path()
        : transactionAutomationsApi.update.path({ id: transactionAutomation.value.id });
    });

    onMounted(() => {
      modalStore.registerModal(TRANSACTION_AUTOMATION_FORM_ID);
      updateDataWithDefaultValues();
    });

    const updateDataWithDefaultValues = () => {
      if (isNewRecord.value) {
        transactionAutomation.value.amountType = 'debit';
        transactionAutomation.value.scheduleType = 'M';
        transactionAutomation.value.scheduleInterval = '1';
      }

      if (transactionAutomation.value.transactionAmount) {
        if (!transactionAutomation.value.originalAmount) {
          transactionAutomation.value.originalAmount = transactionAutomation.value.transactionAmount;
        }

        transactionAutomation.value.amountType = transactionAutomation.value.originalAmount > 0 ? 'credit' : 'debit';
        transactionAutomation.value.transactionAmount = Math.abs(transactionAutomation.value.transactionAmount)
          .toFixed(2);
      }
    };

    const handleSubmit = (closeModal) => {
      loading.value = true;
      if (transactionAutomation.value.amountType === 'debit') {
        transactionAutomation.value.transactionAmount *= -1;
      }

      const fetchOptions = actionName.value === 'show'
        ? { fetchSingle: true, fetchCollection: false }
        : { fetchCollection: true };

      if (isNewRecord.value) {
        transactionAutomationStore
          .create(transactionAutomation.value, fetchOptions)
          .then(closeModal)
          .finally(() => loading.value = false);
      } else {
        transactionAutomationStore
          .update(transactionAutomation.value.id, transactionAutomation.value, fetchOptions)
          .then(closeModal)
          .finally(() => loading.value = false);
      }
    };

    return {
      t,
      loading,
      formMethod,
      formAction,
      currencySymbol,
      scheduleTypeOptions,
      transactionAutomation,
      modalId,
      updateDataWithDefaultValues,
      handleSubmit,
      TRANSACTION_AUTOMATION_FORM_ID,
    };
  },
};
</script>

<style lang="scss" scoped>
.TransactionAutomationForm__schedule-grid {
  grid-template-columns: repeat(2, 1fr);
}
</style>
