<template>
  <ListItem
    :record="reconciliation"
    :actions-component="ReconciliationActions"
    :item-container-class="`bg-light-subtle side-strip ${sideStripVariant}`"
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
  </ListItem>
</template>

<script>
import { markRaw } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatDate, formatDateTime } from '~/utils/DateUtils.js';
import { reconciliations as reconciliationsApi } from '~/api/all.js';
import { VARIANTS_FOR_RECONCILIATION_STATUSES } from '~/utils/Constants.js';

import ReconciliationActions from '~/components/reconciliations/ReconciliationActions.vue';
import ListItem from '~/components/ui/ListItem.vue';

export default {
  components: { ListItem },

  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    markRaw(ReconciliationActions);
    const t = I18n.scopedTranslator('views.reconciliations.list');
    const showPath = reconciliationsApi.show.path({ id: props.reconciliation.id });

    const sideStripVariant = `side-strip-${VARIANTS_FOR_RECONCILIATION_STATUSES[props.reconciliation.status]}`;

    return {
      t,
      formatDate,
      formatDateTime,
      showPath,
      sideStripVariant,
      ReconciliationActions,
    };
  }
};
</script>
