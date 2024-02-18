<template>
  <FormModal
    :t="t"
    :record="importName"
    :form-id="IMPORT_NAME_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="IMPORT_NAME_FORM_ID"
        :action="formAction"
        :method="formMethod"
        resource="importName"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <FormInput
            v-model="importName.importName"
            field-name="import_name"
            :form-helper="formHelper"
            :label="t('import_name_label')"
            required
          />

          <FormInput
            v-model="importName.transactionName"
            field-name="transaction_name"
            :form-helper="formHelper"
            :label="t('transaction_name_label')"
            required
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
import { importNames as importNamesApi } from '~/api/all.js';
import useImportNamesStore from '~/stores/ImportNameStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { IMPORT_NAME_FORM_ID } from '~/utils/Constants.js';

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
    const t = I18n.scopedTranslator('views.import_names.form');

    const loading = ref(false);

    const modalStore = useModalStore();
    const modalId = modalStore.modalId(IMPORT_NAME_FORM_ID);

    const importNameStore = useImportNamesStore();
    const { importNameForFormModal: importName } = storeToRefs(importNameStore);

    const isNewRecord = computed(() => !importName.value.id);
    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewRecord.value
        ? importNamesApi.create.path()
        : importNamesApi.update.path({ id: importName.value.id });
    });

    onMounted(() => {
      modalStore.registerModal(IMPORT_NAME_FORM_ID);
    });

    const handleSubmit = (closeModal) => {
      loading.value = true;

      if (isNewRecord.value) {
        importNameStore
          .create(importName.value)
          .then(closeModal)
          .catch(() => {})
          .finally(() => loading.value = false);
      } else {
        importNameStore
          .update(importName.value.id, importName.value)
          .then(closeModal)
          .catch(() => {})
          .finally(() => loading.value = false);
      }
    };

    return {
      t,
      loading,
      formMethod,
      formAction,
      importName,
      modalId,
      handleSubmit,
      IMPORT_NAME_FORM_ID,
    };
  },
};
</script>
