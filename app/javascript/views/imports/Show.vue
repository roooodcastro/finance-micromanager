<template>
  <PageHeader
    :title="t('title')"
    :back-button-href="importsPath"
  />

  {{ importObject.fileName }}
</template>

<script>
import I18n from '~/utils/I18n.js';
import { imports as importsApi } from '~/api/all.js';

import PageHeader from '~/components/layout/PageHeader.vue';

export default {
  components: {
    PageHeader,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.show');
    const importsPath = importsApi.index.path();

    return {
      t,
      importsPath,
    };
  },
};
</script>
