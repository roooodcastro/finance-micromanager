<template>
  <div class="GridRow__left">
    <div>
      {{ t('import_desc', { file_name: importObject.fileName, source: I18n.t(`activerecord.attributes.import.sources.${importObject.source}`) }) }}
    </div>
    <div>
      {{ importObject.wallet.name }}
    </div>
    <div>
      {{ t(`desc_${importObject.status}`, { start_date: formatDateTime(importObject.createdAt), date: formatDateTime(importObject.updatedAt) }) }}
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

import { formatDateTime } from '~/utils/DateUtils.js';

export default {
  props: {
    importObject: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.list');

    return {
      I18n,
      t,
      formatDateTime,
    };
  }
};
</script>
