<template>
  <div class="list-group-item d-flex align-items-center justify-content-between py-2 ps-2 bg-light-subtle">
    <span>
      {{ formatDate(reconciliation.date) }}
    </span>

    <span>
      {{ reconciliation.status }}
    </span>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';

export default {
  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.reconciliations.list');

    return {
      t,
      formatDate,
    };
  }
};
</script>
