<template>
  <ListItemDrawerContextMenu class="list-group-item overflow-hidden p-0">
    <template v-slot:actions>
      <ReconciliationActions
        :reconciliation="reconciliation"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div
        class="d-flex align-items-center bg-light-subtle side-strip ps-3"
        :class="sideStripVariant"
      >
        <a
          class="text-decoration-none list-group-item-action d-flex align-items-center p-2 min-width-0"
          :href="showPath"
        >
          <div class="d-flex flex-column min-width-0">
            <span class="text-truncate">
              {{ t('name', { date: formatDate(reconciliation.date) }) }}
            </span>
            <span class="fs-6 text-truncate">
              {{ t(`desc_${reconciliation.status}`, { date: formatDateTime(reconciliation.updatedAt) }) }}
            </span>
          </div>
        </a>

        <div class="d-none d-lg-flex ms-auto pe-2 flex-shrink-0">
          <ReconciliationActions :reconciliation="reconciliation" />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { formatDate, formatDateTime } from '~/utils/DateUtils.js';
import { reconciliations as reconciliationsApi } from '~/api/all.js';
import { VARIANTS_FOR_RECONCILIATION_STATUSES } from '~/utils/Constants.js';

import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';
import ReconciliationActions from '~/components/reconciliations/ReconciliationActions.vue';

export default {
  components: {
    ListItemDrawerContextMenu,
    ReconciliationActions,
  },

  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.reconciliations.list');
    const showPath = reconciliationsApi.show.path({ id: props.reconciliation.id });

    const sideStripVariant = `side-strip-${VARIANTS_FOR_RECONCILIATION_STATUSES[props.reconciliation.status]}`;

    return {
      t,
      formatDate,
      formatDateTime,
      showPath,
      sideStripVariant,
    };
  }
};
</script>
