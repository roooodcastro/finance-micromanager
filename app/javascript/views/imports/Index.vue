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

    <DragDropUploadContainer
      :instructions-text="t('drag_drop_instructions_text')"
      :instructions-text-dragging="t('drag_drop_instructions_text_dragging')"
      accepted-file-extensions=".csv,.xls,.xlsx,.pdf"
      class="d-none d-lg-block mb-3"
      @change="handleDragDrop"
    />

    <ImportsList />

    <ImportForm />
  </div>
</template>

<script>
import { nextTick } from 'vue';

import I18n from '~/utils/I18n.js';
import useImportStore from '~/stores/ImportStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import { onProfileChanged } from '~/utils/OnProfileChangeWatcher.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import ImportForm from '~/components/imports/ImportForm.vue';
import ImportsList from '~/components/imports/ImportsList.vue';
import DragDropUploadContainer from '~/components/ui/DragDropUploadContainer.vue';

export default {
  components: {
    DragDropUploadContainer,
    DropdownMenuItem,
    ImportForm,
    ImportsList,
    PageHeader,
  },

  props: {
    imports: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.index');
    const importStore = useImportStore();
    importStore.setActionName('index');

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.imports.floating_button_label'),
      icon: 'cloud-arrow-up',
      callback: () => importStore.openFormModal(null),
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    onProfileChanged(() => importStore.fetchCollection());

    importStore.loadCollectionFromProps(props.imports);

    const handleNew = () => importStore.openFormModal(null);
    const handleDragDrop = async (file) => {
      await nextTick();
      importStore.openFormModal(null, { sourceFile: file });
    };

    return {
      t,
      handleNew,
      handleDragDrop,
    };
  },
};
</script>
