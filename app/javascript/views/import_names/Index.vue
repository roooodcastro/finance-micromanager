<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :label="t('new')"
          icon="plus"
          @click="handleNew"
        />
      </template>
    </PageHeader>

    <ImportNamesList />

    <ImportNameForm />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useImportNameStore from '~/stores/ImportNameStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import { onProfileChanged } from '~/utils/OnProfileChangeWatcher.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import ImportNameForm from '~/components/import_names/ImportNameForm.vue';
import ImportNamesList from '~/components/import_names/ImportNamesList.vue';

export default {
  components: {
    DropdownMenuItem,
    ImportNameForm,
    ImportNamesList,
    PageHeader,
  },

  props: {
    importNames: {
      type: Array,
      required: true,
    },
    pagination: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const importNameStore = useImportNameStore();
    importNameStore.setActionName('index');

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.import_names.floating_button_label'),
      icon: 'right-left',
      callback: () => importNameStore.openFormModal(null),
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    onProfileChanged(() => importNameStore.fetchCollection());

    const paginationStore = usePaginationStore();
    const { pagination: paginationFromStore } = storeToRefs(paginationStore);
    paginationFromStore.value = props.pagination;

    importNameStore.loadCollectionFromProps(props.importNames);

    const handleNew = () => importNameStore.openFormModal(null);

    return {
      t: I18n.scopedTranslator('views.import_names.index'),
      paginationFromStore,
      handleNew,
    };
  },
};
</script>
