<template>
  <FormModal
    :t="t"
    :record="importObject"
    :form-id="IMPORT_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
    @show="handleShow"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="IMPORT_FORM_ID"
        :action="formAction"
        method="POST"
        resource="importObject"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <label
            :for="formHelper.fieldId('wallet_id')"
            class="form-label"
          >
            {{ t('wallet_id_label') }}
          </label>

          <WalletsSelect
            :id="formHelper.fieldId('wallet_id')"
            v-model="importObject.walletId"
            :name="formHelper.fieldName('wallet_id')"
            class="mb-3"
            required
          />

          <label
            :for="formHelper.fieldId('source')"
            class="form-label"
          >
            {{ t('source_label') }}
          </label>

          <FormSelect
            v-model="importObject.source"
            :options="sourceOptions"
            field-name="source"
            :form-helper="formHelper"
            required
          />
        </template>
      </RailsForm>
    </template>
  </FormModal>
</template>

<script>

import { onMounted, ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { imports as importsApi } from '~/api/all.js';
import useImportsStore from '~/stores/ImportStore.js';
import useModalStore from '~/stores/ModalStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import { IMPORT_FORM_ID } from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormModal from '~/components/forms/FormModal.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';
import FormSelect from '~/components/forms/FormSelect.vue';

export default {
  components: {
    FormSelect,
    WalletsSelect,
    FormModal,
    RailsForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.form');

    const loading = ref(false);
    const sourceOptions = [
      { label: t('source_n26_label'), value: 'n26' },
      { label: t('source_ptsb_label'), value: 'ptsb' },
      { label: t('source_revolut_label'), value: 'revolut' },
    ]

    const modalStore = useModalStore();
    const walletStore = useWalletStore();
    const importStore = useImportsStore();

    const modalId = modalStore.modalId(IMPORT_FORM_ID);
    const { activeWallets } = storeToRefs(walletStore);
    const { importForFormModal: importObject } = storeToRefs(importStore);

    const formAction = importsApi.create.path();

    onMounted(() => {
      modalStore.registerModal(IMPORT_FORM_ID);
    });

    const handleShow = () => {
      if (!activeWallets.value.length) {
        walletStore.fetchCollection();
      }
    };

    const handleSubmit = (closeModal) => {
      loading.value = true;

      importStore
        .create(importObject.value)
        .then(closeModal)
        .catch(() => {})
        .finally(() => loading.value = false);
    };

    return {
      t,
      sourceOptions,
      loading,
      formAction,
      importObject,
      modalId,
      handleShow,
      handleSubmit,
      IMPORT_FORM_ID,
    };
  },
};
</script>
