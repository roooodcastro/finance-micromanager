<template>
  <ListItem
    :record="importName"
    :actions-component="ImportNameActions"
  >
    <div class="d-flex align-items-center p-2 ps-3 min-width-0 gap-2">
      {{ t('name_description', { import_name: importName.importName, transaction_name: importName.transactionName }) }}
    </div>
  </ListItem>
</template>

<script>
import { markRaw } from 'vue';

import I18n from '~/utils/I18n.js';

import ImportNameActions from '~/components/import_names/ImportNameActions.vue';
import ListItem from '~/components/ui/ListItem.vue';

export default {
  components: { ListItem },

  props: {
    importName: {
      type: Object,
      required: true,
    },
  },

  setup() {
    markRaw(ImportNameActions);
    const t = I18n.scopedTranslator('views.import_names.list');

    return {
      t,
      ImportNameActions,
    };
  }
};
</script>
