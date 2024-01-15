<template>
  <FormModal
    :t="t"
    :record="{}"
    :form-id="MASS_EDIT_TRANSACTION_FORM_ID"
    :modal-id="modalId"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="MASS_EDIT_TRANSACTION_FORM_ID"
        method="POST"
        resource="transaction"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <InfoAlert :message="t('editing_x_transactions', { count: massEditTransactionIdsCount })" />

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
          />

          <template v-if="showWalletField">
            <label
              :for="formHelper.fieldId('wallet_id')"
              class="form-label mt-3"
            >
              {{ t('wallet_label') }}
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
import { computed, onMounted, ref } from 'vue';
import { storeToRefs } from 'pinia';
import _ from 'lodash';

import I18n from '~/utils/I18n.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useModalStore from '~/stores/ModalStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import { MASS_EDIT_TRANSACTION_FORM_ID } from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormModal from '~/components/forms/FormModal.vue';
import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';
import InfoAlert from '~/components/bootstrap/InfoAlert.vue';

export default {
  components: {
    InfoAlert,
    WalletsSelect,
    CategoriesSelect,
    FormModal,
    RailsForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.transactions.mass_edit_form');

    const categoryStore = useCategoryStore();
    const transactionStore = useTransactionStore();
    const modalStore = useModalStore();
    const walletStore = useWalletStore();

    const modalId = modalStore.modalId(MASS_EDIT_TRANSACTION_FORM_ID);

    const { categories } = storeToRefs(categoryStore);
    const { activeWallets } = storeToRefs(walletStore);
    const { massEditTransactionIdsCount } = storeToRefs(transactionStore);

    const transactionFields = ['categoryId', 'walletId'];

    const transaction = ref({});

    const showWalletField = computed(() => !!activeWallets.value.length);
    const transactionData = computed(() => _.pick(transaction.value, transactionFields));

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    if (!activeWallets.value.length) {
      walletStore.fetchCollection();
    }

    onMounted(() => modalStore.registerModal(MASS_EDIT_TRANSACTION_FORM_ID));

    const handleSubmit = (closeModal) => {
      if (!!transactionData.value.categoryId || !!transactionData.value.walletId) {
        transactionStore.massUpdate(transactionData.value).then(closeModal);
      }
    }

    return {
      t,
      transaction,
      massEditTransactionIdsCount,
      modalId,
      showWalletField,
      handleSubmit,
      MASS_EDIT_TRANSACTION_FORM_ID,
    };
  },
};
</script>
