<template>
  <FormModal
    :t="t"
    :record="wallet"
    :form-id="WALLET_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="WALLET_FORM_ID"
        :action="formAction"
        :method="formMethod"
        resource="wallet"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <FormInput
            v-model="wallet.name"
            field-name="name"
            :form-helper="formHelper"
            :label="t('name_label')"
            class="focus"
          />
        </template>
      </RailsForm>
    </template>
  </FormModal>
</template>

<script>
import { computed, ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { wallets as walletsApi } from '~/api/all.js';
import useWalletsStore from '~/stores/WalletStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { WALLET_FORM_ID } from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import FormModal from '~/components/forms/FormModal.vue';

export default {
  components: {
    FormInput,
    FormModal,
    RailsForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.wallets.form');

    const loading = ref(false);

    const modalStore = useModalStore();

    const modalId = modalStore.modalId(WALLET_FORM_ID);

    const walletStore = useWalletsStore();
    const { walletForFormModal: wallet } = storeToRefs(walletStore);

    const isNewRecord = computed(() => !wallet.value.id);

    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewRecord.value
        ? walletsApi.create.path()
        : walletsApi.update.path({ id: wallet.value.id });
    });

    const handleSubmit = (closeModal) => {
      loading.value = true;
      if (isNewRecord.value) {
        walletStore
          .create({ name: wallet.value.name ?? '' })
          .then(closeModal)
          .finally(() => loading.value = false);
      } else {
        walletStore
          .update(wallet.value.id, { name: wallet.value.name })
          .then(closeModal)
          .finally(() => loading.value = false);
      }
    };

    return {
      t,
      loading,
      formMethod,
      formAction,
      wallet,
      modalId,
      handleSubmit,
      WALLET_FORM_ID,
    };
  },
};
</script>
