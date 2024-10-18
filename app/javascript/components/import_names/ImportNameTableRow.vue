<template>
  <div class="GridRow__left">
    <div>
      {{ importName.importName }}
    </div>
  </div>

  <div class="GridRow__right">
    <div>
      {{ importName.transactionName }}
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

export default {
  props: {
    importName: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.import_names.list');

    return {
      t,
    };
  }
};
</script>
