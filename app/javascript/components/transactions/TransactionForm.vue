<template>
  <FormModal
    :t="t"
    :record="transaction"
    :form-id="TRANSACTION_FORM_ID"
    :modal-id="modalId"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="TRANSACTION_FORM_ID"
        method="POST"
        resource="transaction"
        @submit.prevent="handleSubmit(closeModal)"
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
            />
          </template>
        </template>
      </RailsForm>
    </template>
  </FormModal>
</template>

<script>
import { computed, onMounted, watch } from 'vue';
import { storeToRefs } from 'pinia';
import _ from 'lodash';

import { transactions as transactionsApi } from '~/api';
import I18n from '~/utils/I18n';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useModalStore from '~/stores/ModalStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import { parseLocaleNumber } from '~/utils/NumberFormatter.js';
import { TRANSACTION_FORM_ID } from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import FormModal from '~/components/forms/FormModal.vue';
import ToggleSwitch from '~/components/ui/ToggleSwitch.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';

export default {
  components: {
    WalletsSelect,
    CategoriesSelect,
    FormInput,
    FormModal,
    RailsForm,
    ToggleSwitch,
  },

  setup() {
    const t = I18n.scopedTranslator('views.transactions.form');

    const profileStore = useProfileStore();
    const categoryStore = useCategoryStore();
    const transactionStore = useTransactionStore();
    const modalStore = useModalStore();
    const walletStore = useWalletStore();

    const modalId = modalStore.modalId(TRANSACTION_FORM_ID);

    const { currentProfile } = storeToRefs(profileStore);
    const { categories } = storeToRefs(categoryStore);
    const { transactionForFormModal: transaction, transactions } = storeToRefs(transactionStore);
    const { activeWallets } = storeToRefs(walletStore);

    const showWalletField = computed(() => !!activeWallets.value.length);

    if (!categories.value.length) {
      categoryStore.fetch();
    }

    const isNewRecord = computed(() => !transaction.value.id);
    const currencySymbol = computed(() => currentProfile.value.currencyObject.symbol);

    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewRecord.value
        ? transactionsApi.create.path()
        : transactionsApi.update.path({ id: transaction.value.id });
    });

    const updateTransactionDataWithDefaultValues = () => {
      if (transaction.value.amount) {
        transaction.value.amount = Math.abs(parseLocaleNumber(transaction.value.amount)).toFixed(2);
      }

      if (!activeWallets.value.length) {
        walletStore.fetch();
      }

      if (isNewRecord.value) {
        transaction.value.walletId = currentProfile.value.defaultWalletId;
      }

      transaction.value.amountType =  transaction.value.amountCents > 0 ? 'credit' : 'debit';

      const defaultTransactionDate = new Date().toISOString().split('T')[0];
      transaction.value.transactionDate = transaction.value.transactionDate || defaultTransactionDate;
    };

    watch(
      [transaction, transactions],
      updateTransactionDataWithDefaultValues,
    );

    onMounted(() => {
      modalStore.registerModal(TRANSACTION_FORM_ID);

      updateTransactionDataWithDefaultValues();
    });

    const handleSubmit = (closeModal) => {
      const transactionFields = ['name', 'amount', 'transactionDate', 'amountType', 'categoryId', 'walletId'];
      const transactionData = _.pick(transaction.value, transactionFields);
      if (isNewRecord.value) {
        transactionStore.create(transactionData).then(closeModal);
      } else {
        transactionStore.update(transaction.value.id, transactionData).then(closeModal);
      }
    }

    return {
      t,
      currencySymbol,
      formMethod,
      formAction,
      transaction,
      modalId,
      showWalletField,
      handleSubmit,
      TRANSACTION_FORM_ID,
    };
  },
};
</script>
