<template>
  <FormModal
    :t="t"
    :record="reconciliation"
    :form-id="RECONCILIATION_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="RECONCILIATION_FORM_ID"
        :action="formAction"
        :method="formMethod"
        resource="reconciliation"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <FormInput
            v-model="reconciliation.date"
            field-name="date"
            :form-helper="formHelper"
            :label="t('date_label')"
            type="date"
            class="focus"
            required
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
import { reconciliations as reconciliationsApi } from '~/api/all.js';
import useReconciliationsStore from '~/stores/ReconciliationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { RECONCILIATION_FORM_ID } from '~/utils/Constants.js';

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
    const t = I18n.scopedTranslator('views.reconciliations.form');

    const loading = ref(false);

    const modalStore = useModalStore();

    const modalId = modalStore.modalId(RECONCILIATION_FORM_ID);

    const reconciliationStore = useReconciliationsStore();
    const { reconciliationForFormModal: reconciliation } = storeToRefs(reconciliationStore);

    const isNewRecord = computed(() => !reconciliation.value.id);

    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewRecord.value
        ? reconciliationsApi.create.path()
        : reconciliationsApi.update.path({ id: reconciliation.value.id });
    });

    const handleSubmit = (closeModal) => {
      loading.value = true;
      if (isNewRecord.value) {
        reconciliationStore
          .create({ date: reconciliation.value.date })
          .then((response) => {
            window.location.href = reconciliationsApi.show.path({ id: response.reconciliation.id });
          })
          .catch(() => {})
          .finally(() => loading.value = false);
      } else {
        reconciliationStore
          .update(reconciliation.value.id, { date: reconciliation.value.date })
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
      reconciliation,
      modalId,
      handleSubmit,
      RECONCILIATION_FORM_ID,
    };
  },
};
</script>
