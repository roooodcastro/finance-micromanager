<template>
  <FormModal
    :t="t"
    :record="budget"
    :form-id="BUDGET_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
    @show="handleShow"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="BUDGET_FORM_ID"
        :action="formAction"
        method="PATCH"
        resource="budget"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <label
            :for="formHelper.fieldId('limit_type')"
            class="form-label"
          >
            {{ t('limit_type_label') }}
          </label>

          <LimitTypeSelect
            :id="formHelper.fieldId('limit_type')"
            v-model="budget.limitType"
            :name="formHelper.fieldName('limit_type')"
            :limit-owner-type="budget.ownerType"
            required
            @change="handleLimitTypeChange"
          />

          <template v-if="budget.limitType === BUDGET_LIMIT_TYPE_ABSOLUTE">
            <label
              :for="formHelper.fieldId('limit_amount')"
              class="form-label"
            >
              {{ t('limit_label') }}
            </label>

            <div class="input-group mb-3">
              <span class="input-group-text">
                {{ currencySymbol }}
              </span>

              <input
                :id="formHelper.fieldId('limit_amount')"
                v-model="budget.limitAmount"
                :name="formHelper.fieldName('limit_amount')"
                type="number"
                class="form-control"
                step="0.01"
                min="0"
                required
              >
            </div>
          </template>
          <template v-if="budget.limitType === BUDGET_LIMIT_TYPE_PERCENTAGE">
            <label
              :for="formHelper.fieldId('limit_percentage')"
              class="form-label"
            >
              {{ t('limit_label') }}
            </label>

            <div class="input-group mb-3">
              <span class="input-group-text">
                %
              </span>

              <input
                :id="formHelper.fieldId('limit_percentage')"
                v-model="budget.limitPercentage"
                :name="formHelper.fieldName('limit_percentage')"
                type="number"
                class="form-control"
                step="0.1"
                min="0"
                max="100"
                required
              >
            </div>
          </template>
        </template>
      </RailsForm>
    </template>
  </FormModal>
</template>

<script>
import { computed, ref, onMounted } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';

import { budgets as budgetsApi } from '~/api/all.js';

import useBudgetStore from '~/stores/BudgetStore.js';
import useModalStore from '~/stores/ModalStore.js';
import useProfileStore from '~/stores/ProfileStore.js';

import {
  BUDGET_FORM_ID,
  BUDGET_LIMIT_TYPE_ABSOLUTE,
  BUDGET_LIMIT_TYPE_PERCENTAGE,
  BUDGET_OWNER_TYPE_PROFILE,
} from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormModal from '~/components/forms/FormModal.vue';
import LimitTypeSelect from '~/components/budgets/LimitTypeSelect.vue';

export default {
  components: {
    FormModal,
    LimitTypeSelect,
    RailsForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.budgets.form');

    const loading = ref(false);

    const modalStore = useModalStore();
    const modalId = modalStore.modalId(BUDGET_FORM_ID);

    const budgetStore = useBudgetStore();
    const profileStore = useProfileStore();

    const { currentProfile } = storeToRefs(profileStore);
    const { budgetForFormModal: budget } = storeToRefs(budgetStore);

    const isNewRecord = computed(() => !budget.value.id);

    const formAction = isNewRecord.value
      ? budgetsApi.create.path()
      : budgetsApi.update.path({ id: budget.value.id });

    const submitButtonLabel = computed(() => isNewRecord.value ? t('submit_create') : t('submit_update'));

    const handleSubmit = (closeModal) => {
      loading.value = true;
      if (isNewRecord.value) {
        const isProfileBudget = budget.value.ownerType === BUDGET_OWNER_TYPE_PROFILE;
        budgetStore
          .create(budget.value)
          .then(() => {
            if (isProfileBudget) {
              budgetStore.fetchProfileBudget();
            }
            closeModal();
          })
          .catch(() => {})
          .finally(() => loading.value = false);
      } else {
        budgetStore
          .update(budget.value.id, budget.value)
          .then(() => {
            if (budget.value.ownerType === BUDGET_OWNER_TYPE_PROFILE) {
              budgetStore.fetchProfileBudget();
            }
            closeModal();
          })
          .catch(() => {})
          .finally(() => loading.value = false);
      }
    };

    const currencySymbol = computed(() => currentProfile.value.currencyObject.symbol);

    const setDefaultValues = () => {
      budget.value.limitType = budget.value.limitType ?? BUDGET_LIMIT_TYPE_ABSOLUTE;
    };

    onMounted(() => {
      setDefaultValues();
    });

    const handleShow = () => {
      setDefaultValues();
    };

    const handleLimitTypeChange = () => {
      budget.value.limitAmount = null;
      budget.value.limitPercentage = '';
    }

    return {
      t,
      loading,
      modalId,
      budget,
      formAction,
      submitButtonLabel,
      currencySymbol,
      handleSubmit,
      handleShow,
      handleLimitTypeChange,
      BUDGET_FORM_ID,
      BUDGET_LIMIT_TYPE_ABSOLUTE,
      BUDGET_LIMIT_TYPE_PERCENTAGE,
    };
  },
};
</script>
