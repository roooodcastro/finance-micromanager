<template>
  <div
    class="d-flex mt-3 align-items-center justify-content-center sticky-bottom bg-white p-3 gap-3 shadow"
  >
    <button
      type="submit"
      class="btn btn-primary"
    >
      <FontAwesomeIcon icon="cloud-arrow-up" />
      {{ t('submit_button') }}
    </button>

    <RailsForm
      method="DELETE"
      :action="destroyPath"
      @submit.prevent="submitCancelForm"
    >
      <button
        type="submit"
        class="btn btn-outline-secondary"
      >
        <FontAwesomeIcon icon="ban" />
        {{ t('cancel_button') }}
      </button>
    </RailsForm>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { imports as importsApi } from '~/api/all.js';
import useImportStore from '~/stores/ImportStore.js';
import useModalStore from '~/stores/ModalStore.js';

import RailsForm from '~/components/rails/RailsForm.vue';

export default {
  components: {
    FontAwesomeIcon,
    RailsForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.preview');

    const importStore = useImportStore();
    const modalStore = useModalStore();
    const { import: importObject } = storeToRefs(importStore);

    const destroyPath = importsApi.destroy.path({ id: importObject.value.id });

    const submitCancelForm = (event) => {
      modalStore
        .showConfirmationDialog({ message: I18n.t('views.imports.confirmation.cancel') })
        .then(() => event.target.submit());
    };

    return {
      t,
      destroyPath,
      submitCancelForm,
    };
  },
};
</script>
