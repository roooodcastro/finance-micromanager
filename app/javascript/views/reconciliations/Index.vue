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
import I18n from '~/utils/I18n.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import usePaginationStore from '~/stores/PaginationStore.js';

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
    reconciliationStore.loadFromProps(props.reconciliations);

    const handleNew = () => reconciliationStore.openFormModal(null);

    return {
      t: I18n.scopedTranslator('views.reconciliations.index'),
      handleNew,
    };
  },
};
</script>