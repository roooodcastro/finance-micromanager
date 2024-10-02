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

    <ReconciliationForm />
    <ReconciliationsList />
  </div>
</template>

<script>
import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import { ICON_RECONCILIATIONS } from '~/utils/Constants.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import ReconciliationForm from '~/components/reconciliations/ReconciliationForm.vue';
import ReconciliationsList from '~/components/reconciliations/ReconciliationsList.vue';

export default {
  components: {
    DropdownMenuItem,
    ReconciliationForm,
    ReconciliationsList,
    PageHeader,
  },

  props: {
    reconciliations: {
      type: Array,
      required: true,
    },
    pagination: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const paginationStore = usePaginationStore();
    paginationStore.setPaginationOptions(props.pagination);

    const reconciliationStore = useReconciliationStore();
    reconciliationStore.loadCollectionFromProps(props.reconciliations);

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.reconciliations.floating_button_label'),
      icon: ICON_RECONCILIATIONS,
      callback: () => reconciliationStore.openFormModal(null),
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => reconciliationStore.fetchCollection());

    const handleNew = () => reconciliationStore.openFormModal(null);

    return {
      t: I18n.scopedTranslator('views.reconciliations.index'),
      handleNew,
    };
  },
};
</script>
