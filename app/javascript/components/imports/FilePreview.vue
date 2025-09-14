<template>
  <div class="card">
    <div class="card-body d-flex align-items-center">
      <template v-if="!!file">
        <FontAwesomeIcon
          :icon="fileTypeIcon"
          size="xl"
          class="me-3"
        />
        {{ file.name }}
      </template>
      <template v-else>
        {{ t('no_file_selected') }}
      </template>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    file: {
      type: File,
      default: null,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.components.imports.file_preview');

    const fileTypeIcons = {
      'text/csv': 'file-csv',
      'application/pdf': 'file-pdf',
      'application/vnd.ms-excel': 'file-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'file-excel'
    };

    const fileTypeIcon = computed(() => fileTypeIcons[props.file.type] ?? 'file');

    return {
      t,
      fileTypeIcon,
    };
  }
};
</script>
