<template>
  <FormModal
    :t="t"
    :record="importObject"
    :form-id="IMPORT_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
    @show="handleShow"
  >
    <RailsForm
      :id="IMPORT_FORM_ID"
      :action="formAction"
      method="POST"
      resource="import"
      enctype="multipart/form-data"
      @submit.prevent="handleSubmit"
    >
      <template v-slot:default="{ formHelper }">
        <FormInput
          ref="sourceFileInput"
          v-model="importObject.sourceFile"
          :form-helper="formHelper"
          field-name="source_file"
          :label="t('source_file_label')"
          type="file"
          accept=".csv,.xls,.xlsx"
        />

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
import FormInput from '~/components/rails/FormInput.vue';

export default {
  components: {
    FormInput,
    FormModal,
    FormSelect,
    RailsForm,
    WalletsSelect,
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.form');

    const sourceFileInput = ref(null);
    const loading = ref(false);
    const sourceOptions = [
      { label: t('source_n26_label'), value: 'n26' },
      { label: t('source_ptsb_label'), value: 'ptsb' },
      // { label: t('source_revolut_label'), value: 'revolut' },
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

    const handleSubmit = () => {
      loading.value = true;

      const file = sourceFileInput.value.$el.querySelector('input').files[0];

      importStore
        .create({ ...importObject.value, sourceFile: file })
        .then(() => window.location.href = importsApi.index.path())
        .catch(() => loading.value = false)
    };

    return {
      t,
      sourceOptions,
      loading,
      sourceFileInput,
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
