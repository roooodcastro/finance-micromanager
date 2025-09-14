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
        <input
          ref="sourceFileInput"
          type="file"
          accept=".csv,.xls,.xlsx,.pdf"
          class="d-none"
          @change="handleFileSelected"
        >

        <button
          class="btn btn-sm btn-outline-primary w-100 mb-2"
          @click="handleBrowseFileClick"
          v-html="t('browse_file')"
        />

        <FilePreview
          :file="importObject.sourceFile"
          class="mb-3"
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
import FilePreview from '~/components/imports/FilePreview.vue';

export default {
  components: {
    FilePreview,
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

    const handleFileSelected = (ev) => importObject.value.sourceFile = ev.target.files[0];

    const handleBrowseFileClick = (ev) => {
      ev.preventDefault();
      sourceFileInput.value.click();
    }

    const handleSubmit = () => {
      loading.value = true;

      importStore
        .create(importObject.value)
        .then((response) => window.location.href = importsApi.show.path({ id: response.importId }))
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
      handleFileSelected,
      handleShow,
      handleSubmit,
      handleBrowseFileClick,
      IMPORT_FORM_ID,
    };
  },
};
</script>
