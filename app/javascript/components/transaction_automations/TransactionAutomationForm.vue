<template>
  <FormModal
    :t="t"
    :record="transactionAutomation"
    :form-id="TRANSACTION_AUTOMATION_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
    @show="handleShow"
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

          <nav class="nav nav-pills nav-justified mb-3">
            <a
              href="#"
              class="nav-link text-center"
              :class="{ active: !transactionAutomation.isCustomRule }"
              @click="handleNormalTabClick"
            >
              {{ t('normal_rule_tab_title') }}
            </a>
            <a
              href="#"
              class="nav-link text-center"
              :class="{ active: transactionAutomation.isCustomRule }"
              @click="handleCustomTabClick"
            >
              {{ t('custom_rule_tab_title') }}
            </a>
          </nav>

          <div v-if="!transactionAutomation.isCustomRule">
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
                @change="resetScheduleDay"
              />
            </div>
          </div>

          <div v-else>
            <label
              :for="formHelper.fieldId('schedule_custom_rule')"
              class="form-label"
            >
              {{ t('schedule_type_interval_label') }}
            </label>

            <FormSelect
              v-model="transactionAutomation.scheduleCustomRule"
              :options="scheduleCustomRuleOptions"
              field-name="schedule_custom_rule"
              :form-helper="formHelper"
              class="flex-grow-1 mb-3"
              required
            />
          </div>

          <div
            v-if="showScheduleDay"
            class="mb-3"
          >
            <label
              :for="formHelper.fieldId('schedule_day')"
              class="form-label"
            >
              {{ t(`schedule_day_of_${transactionAutomation.scheduleType === 'M' ? 'month' : 'week'}_label`) }}
            </label>

            <FormSelect
              v-model="transactionAutomation.scheduleDay"
              :options="scheduleDayOptions"
              field-name="schedule_day"
              :form-helper="formHelper"
              class="flex-grow-1"
              required
            />
          </div>

          <FormInput
            v-else
            v-model="transactionAutomation.scheduledDate"
            field-name="scheduled_date"
            :form-helper="formHelper"
            :label="t('next_schedule_date_label')"
            type="date"
            required
          />

          <div
            v-if="showWeekendRule"
            class="mb-3"
          >
            <label
              :for="formHelper.fieldId('weekend_rule')"
              class="form-label"
            >
              {{ t('weekend_rule_label') }}
            </label>

            <FormSelect
              v-model="transactionAutomation.weekendRule"
              :options="weekendRuleOptions"
              field-name="weekend_rule"
              :form-helper="formHelper"
              class="flex-grow-1"
              required
            />
          </div>

          <CheckboxField
            :id="formHelper.fieldId('create_at_start_of_period')"
            v-model="transactionAutomation.createAtStartOfPeriod"
            :name="formHelper.fieldName('create_at_start_of_period')"
          >
            {{ t('create_at_start_of_period_label') }}
            <InfoTooltip :message="t('create_at_start_of_period_tooltip')" />
          </CheckboxField>

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
import _ from 'lodash';

import I18n from '~/utils/I18n.js';
import { transactionAutomations as transactionAutomationsApi } from '~/api/all.js';
import useTransactionAutomationsStore from '~/stores/TransactionAutomationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import { TRANSACTION_AUTOMATION_FORM_ID } from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import FormSelect from '~/components/forms/FormSelect.vue';
import FormModal from '~/components/forms/FormModal.vue';
import ToggleSwitch from '~/components/ui/ToggleSwitch.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';
import CheckboxField from '~/components/forms/CheckboxField.vue';
import InfoTooltip from '~/components/bootstrap/InfoTooltip.vue';

export default {
  components: {
    CategoriesSelect,
    CheckboxField,
    FormInput,
    FormModal,
    FormSelect,
    InfoTooltip,
    RailsForm,
    ToggleSwitch,
    WalletsSelect,
  },

  setup() {
    const t = I18n.scopedTranslator('views.transaction_automations.form');

    const loading = ref(false);

    const scheduleTypeOptions = [
      { value: 'M', label: t('schedule_type_month') },
      { value: 'W', label: t('schedule_type_week') },
      { value: 'D', label: t('schedule_type_day') },
    ];

    const scheduleCustomRuleOptions = [
      { value: 'last_day_of_month', label: t('custom_rule_last_day_of_month') },
      { value: 'first_business_day_of_month', label: t('custom_rule_first_business_day_of_month') },
      { value: 'last_business_day_of_month', label: t('custom_rule_last_business_day_of_month') },
    ]

    const modalStore = useModalStore();
    const profileStore = useProfileStore();
    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();

    const modalId = modalStore.modalId(TRANSACTION_AUTOMATION_FORM_ID);

    const { categories } = storeToRefs(categoryStore);
    const { activeWallets } = storeToRefs(walletStore);
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

    const showScheduleDay = computed(() => {
      return transactionAutomation.value.scheduleType === 'M' || transactionAutomation.value.scheduleType === 'W';
    });

    const showWeekendRule = computed(() => {
      return transactionAutomation.value.scheduleType === 'M' || transactionAutomation.value.scheduleType === 'D';
    });

    const scheduleDayOptions = computed(() => {
      if (transactionAutomation.value.scheduleType === 'M') {
        return [...Array(31)].map((_, i) => {
          return { value: i + 1, label: i + 1 }
        });
      } else {
        return I18n.t('date.day_names').map((weekDay, index) => {
          return { value: index, label: _.upperFirst(weekDay) };
        });
      }
    });

    const weekendRuleOptions = ['allow', 'friday', 'monday'].map((value) => {
      return { value, label: t(`weekend_rule_${value}`) };
    });

    const updateDataWithDefaultValues = () => {
      if (isNewRecord.value) {
        transactionAutomation.value.amountType = 'debit';
        transactionAutomation.value.scheduleType = 'M';
        transactionAutomation.value.scheduleInterval = '1';
        transactionAutomation.value.weekendRule = 'allow';
      }

      transactionAutomation.value.isCustomRule = transactionAutomation.value.scheduleType === 'C';

      if (transactionAutomation.value.transactionAmount) {
        if (!transactionAutomation.value.originalAmount) {
          transactionAutomation.value.originalAmount = transactionAutomation.value.transactionAmount;
        }

        transactionAutomation.value.amountType = transactionAutomation.value.originalAmount > 0 ? 'credit' : 'debit';
        transactionAutomation.value.transactionAmount = Math.abs(transactionAutomation.value.transactionAmount)
          .toFixed(2);
      }
    };

    const handleShow = () => {
      if (!activeWallets.value.length) {
        walletStore.fetchCollection();
      }

      if (!categories.value.length) {
        categoryStore.fetchCollection();
      }

      updateDataWithDefaultValues();
    };

    const handleNormalTabClick = () => {
      transactionAutomation.value.isCustomRule = false;
      transactionAutomation.value.scheduleCustomRule = null;
    };

    const handleCustomTabClick = () => {
      transactionAutomation.value.isCustomRule = true;
      transactionAutomation.value.scheduleType = 'C';
      transactionAutomation.value.scheduleInterval = null;
      transactionAutomation.value.scheduleDay = null;
      transactionAutomation.value.weekendRule = null;
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
          .catch(() => {
            transactionAutomation.value.transactionAmount *= -1;
          })
          .finally(() => loading.value = false);
      } else {
        transactionAutomationStore
          .update(transactionAutomation.value.id, transactionAutomation.value, fetchOptions)
          .then(closeModal)
          .catch(() => {
            transactionAutomation.value.transactionAmount *= -1;
          })
          .finally(() => loading.value = false);
      }
    };

    const resetScheduleDay = () => {
      transactionAutomation.value.scheduleDay = null;
      transactionAutomation.value.weekendRule = null;
    };

    return {
      t,
      loading,
      formMethod,
      formAction,
      currencySymbol,
      scheduleTypeOptions,
      scheduleCustomRuleOptions,
      transactionAutomation,
      modalId,
      showScheduleDay,
      showWeekendRule,
      scheduleDayOptions,
      weekendRuleOptions,
      handleShow,
      handleSubmit,
      handleNormalTabClick,
      handleCustomTabClick,
      resetScheduleDay,
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
