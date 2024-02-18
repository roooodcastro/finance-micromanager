<template>
  <ListItemDrawerContextMenu class="list-group-item p-0 overflow-hidden">
    <template v-slot:actions>
      <ImportNameActions
        :import-name="importName"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div class="d-flex align-items-center bg-light-subtle">
        <div class="d-flex align-items-center p-2 ps-4 min-width-0 gap-2">
          {{ t('name_description', { import_name: importName.importName, transaction_name: importName.transactionName }) }}
        </div>

        <div class="d-none d-lg-flex ms-auto pe-2 flex-shrink-0">
          <ImportNameActions :import-name="importName" />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import I18n from '~/utils/I18n.js';

import ImportNameActions from '~/components/import_names/ImportNameActions.vue';
import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';

export default {
  components: {
    ListItemDrawerContextMenu,
    ImportNameActions,
  },

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
