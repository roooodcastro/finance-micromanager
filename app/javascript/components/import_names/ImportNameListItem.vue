<template>
  <ListItemDrawerContextMenu class="ImportNameListItem list-group-item overflow-hidden p-0">
    <template v-slot:actions>
      <ImportNameActions
        :import-name="importName"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div class="d-flex align-items-center bg-light-subtle">
        <div class="d-flex align-items-center p-2 ps-3 min-width-0 gap-2">
          {{ t('name_description', { import_name: importName.importName, transaction_name: importName.transactionName }) }}
        </div>

        <div class="d-none d-lg-flex ms-auto flex-shrink-0">
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

<style lang="scss" scoped>
.ImportNameListItem:not(:first-child) {
  border-top: none !important;
}
</style>
