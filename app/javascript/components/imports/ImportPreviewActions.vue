<template>
  <div
    class="d-flex mt-3 align-items-center justify-content-center sticky-bottom bg-body-tertiary p-3 gap-3 shadow"
  >
    <div class="text-muted me-3">
      <FontAwesomeIcon
        :icon="previewSaveStateIcon"
        :spin="isSavingPreview"
      />
      {{ t(previewSaveState) }}
    </div>
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
import { computed } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { imports as importsApi } from '~/api/all.js';
import useImportStore from '~/stores/ImportStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { IMPORT_PREVIEW_SAVE_STATES } from '~/utils/Constants.js';

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
    const { import: importObject, previewSaveState } = storeToRefs(importStore);

    const previewSaveStateIcons = {
      [IMPORT_PREVIEW_SAVE_STATES.saved]: ['far', 'floppy-disk'],
      [IMPORT_PREVIEW_SAVE_STATES.saving]: 'spinner',
      [IMPORT_PREVIEW_SAVE_STATES.error]: ['far', 'circle-xmark'],
    };

    const previewSaveStateIcon = computed(() => previewSaveStateIcons[previewSaveState.value]);
    const isSavingPreview = computed(() => previewSaveState === IMPORT_PREVIEW_SAVE_STATES.saving);

    const destroyPath = importsApi.destroy.path({ id: importObject.value.id });

    const submitCancelForm = (event) => {
      modalStore
        .showConfirmationDialog({ message: I18n.t('views.imports.confirmation.cancel') })
        .then(() => event.target.submit());
    };

    return {
      t,
      destroyPath,
      isSavingPreview,
      previewSaveState,
      previewSaveStateIcon,
      submitCancelForm,
    };
  },
};
</script>
