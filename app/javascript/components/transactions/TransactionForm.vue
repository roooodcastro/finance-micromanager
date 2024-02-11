<template>
  <FormModal
    :t="t"
    :record="transaction"
    :form-id="TRANSACTION_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
    @show="handleShow"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="TRANSACTION_FORM_ID"
        method="POST"
        resource="transaction"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <WarningAlert
            v-if="transaction.lockedByReconciliation"
            :message="t('locked_message')"
          />

          <FormInput
            v-model="transaction.name"
            field-name="name"
            :form-helper="formHelper"
            :label="t('name_label')"
            class="focus"
            required
            @input="handleInput"
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
              :off-label="t('debit_label')"
              :on-label="t('credit_label')"
              :off-value="'debit'"
              :on-value="'credit'"
              :disabled="transaction.lockedByReconciliation"
            />
          </div>

          <FormInput
            v-model="transaction.transactionDate"
            field-name="transaction_date"
            :form-helper="formHelper"
            :label="t('date_label')"
            type="date"
            :disabled="transaction.lockedByReconciliation"
            required
            @input="handleInput"
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
            @change="handleInput"
          />

          <template v-if="showWalletField">
            <label
              :for="formHelper.fieldId('wallet_id')"
              class="form-label mt-3"
            >
              {{ t('wallet_label') }}
              <span class="fst-italic">({{ t('optional') }})</span>
            </label>

            <WalletsSelect
              :id="formHelper.fieldId('wallet_id')"
              v-model="transaction.walletId"
              :name="formHelper.fieldName('wallet_id')"
              :disabled="transaction.lockedByReconciliation"
              @change="handleInput"
            />
          </template>
        </template>
      </RailsForm>
    </template>
  </FormModal>
</template>

<script>
import { ref, computed, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import _ from 'lodash';
import dayjs from 'dayjs';

import { transactions as transactionsApi } from '~/api/all.js';
import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';
import useModalStore from '~/stores/ModalStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import { TRANSACTION_FORM_ID } from '~/utils/Constants.js';
import { RulesProcessor } from '~/lib/transaction_predictions/RulesProcessor.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import FormModal from '~/components/forms/FormModal.vue';
import ToggleSwitch from '~/components/ui/ToggleSwitch.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';
import WarningAlert from '~/components/bootstrap/WarningAlert.vue';

export default {
  components: {
    WarningAlert,
    WalletsSelect,
    CategoriesSelect,
    FormInput,
    FormModal,
    RailsForm,
    ToggleSwitch,
  },

  setup() {
    const t = I18n.scopedTranslator('views.transactions.form');

    const loading = ref(false);

    const profileStore = useProfileStore();
    const categoryStore = useCategoryStore();
    const transactionStore = useTransactionStore();
    const modalStore = useModalStore();
    const walletStore = useWalletStore();
    const transactionPredictionStore = useTransactionPredictionStore();

    const modalId = modalStore.modalId(TRANSACTION_FORM_ID);

    const { currentProfile } = storeToRefs(profileStore);
    const { categories } = storeToRefs(categoryStore);
    const { activeWallets } = storeToRefs(walletStore);
    const { transactionPredictions } = storeToRefs(transactionPredictionStore);
    const { transactionForFormModal: transaction, defaultTransactionDate } = storeToRefs(transactionStore);

    const showWalletField = computed(() => !!activeWallets.value.length);

    const isNewRecord = computed(() => !transaction.value.id);
    const currencySymbol = computed(() => currentProfile.value.currencyObject.symbol);

    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewRecord.value
        ? transactionsApi.create.path()
        : transactionsApi.update.path({ id: transaction.value.id });
    });

    const updateTransactionDataWithDefaultValues = () => {
      transaction.value.transactionDate = transaction.value.transactionDate || defaultTransactionDate.value;
      transaction.value.amountType = 'debit';

      if (transaction.value.amount) {
        if (!transaction.value.originalAmount) {
          transaction.value.originalAmount = transaction.value.amount;
        }

        transaction.value.amountType = transaction.value.originalAmount > 0 ? 'credit' : 'debit';
        transaction.value.amount = Math.abs(transaction.value.amount).toFixed(2);
      }

      if (isNewRecord.value) {
        transaction.value.walletId = currentProfile.value.defaultWalletId;
      } else {
        const lastReconciliationDate = dayjs(currentProfile.value.lastReconciliationDate);
        transaction.value.lockedByReconciliation = lastReconciliationDate >= dayjs(transaction.value.transactionDate);
      }
    };

    onMounted(() => {
      modalStore.registerModal(TRANSACTION_FORM_ID);
      updateTransactionDataWithDefaultValues();
    });

    const handleShow = () => {
      if (!categories.value.length) {
        categoryStore.fetchCollection();
      }

      if (!activeWallets.value.length) {
        walletStore.fetchCollection();
      }

      if (!transactionPredictions.value.length) {
        transactionPredictionStore.fetchCollection();
      }

      updateTransactionDataWithDefaultValues();
    }

    const handleSubmit = (closeModal) => {
      loading.value = true;
      const transactionFields = ['name', 'amount', 'transactionDate', 'amountType', 'categoryId', 'walletId'];
      const transactionData = _.pick(transaction.value, transactionFields);

      if (isNewRecord.value) {
        transactionStore
          .create(transactionData)
          .then(closeModal)
          .catch(() => {})
          .finally(() => loading.value = false);
      } else {
        transactionStore
          .update(transaction.value.id, transactionData)
          .then(closeModal)
          .catch(() => {})
          .finally(() => loading.value = false);
      }
    };

    const handleInput = () => {
      if (isNewRecord.value) {
        transaction.value = new RulesProcessor(transaction.value).processTransaction();
      }
    };

    return {
      t,
      loading,
      currencySymbol,
      formMethod,
      formAction,
      transaction,
      modalId,
      showWalletField,
      handleSubmit,
      handleShow,
      handleInput,
      updateTransactionDataWithDefaultValues,
      TRANSACTION_FORM_ID,
    };
  },
};
</script>
