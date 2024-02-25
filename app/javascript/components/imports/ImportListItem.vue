<template>
  <div class="ImportListItem list-group-item overflow-hidden p-0">
    <div
      class="d-flex align-items-center bg-light-subtle side-strip ps-2"
      :class="sideStripVariant"
    >
      <a
        class="text-decoration-none list-group-item-action d-flex align-items-center min-width-0 p-2"
        :href="showPath"
      >
        <div class="d-flex flex-column min-width-0">
          <span class="text-truncate">
            {{ t('import_desc', { file_name: importObject.fileName, source: I18n.t(`activerecord.attributes.import.sources.${importObject.source}`) }) }}
            {{ importObject.wallet.name }}
          </span>
          <span class="fs-6 text-truncate">
            {{ t(`desc_${importObject.status}`, { start_date: formatDateTime(importObject.createdAt), date: formatDateTime(importObject.updatedAt) }) }}
          </span>
        </div>
      </a>
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

import { VARIANTS_FOR_IMPORT_STATUSES } from '~/utils/Constants.js';
import { imports as importsApi } from '~/api/all.js';
import { formatDateTime } from '~/utils/DateUtils.js';

export default {
  props: {
    importObject: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.list');
    const showPath = importsApi.show.path({ id: props.importObject.id });

    const sideStripVariant = `side-strip-${VARIANTS_FOR_IMPORT_STATUSES[props.importObject.status]}`;

    return {
      I18n,
      t,
      showPath,
      sideStripVariant,
      formatDateTime,
    };
  }
};
</script>

<style lang="scss" scoped>
.ImportListItem:not(:first-child) {
  border-top: none !important;
}
</style>
