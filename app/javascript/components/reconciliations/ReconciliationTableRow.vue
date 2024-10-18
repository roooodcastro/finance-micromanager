<template>
  <div class="GridRow__left">
    <div>
      {{ t('name', { date: formatDate(reconciliation.date) }) }}
    </div>
    <div>
      {{ t(`desc_${reconciliation.status}`, { date: formatDateTime(reconciliation.updatedAt) }) }}
    </div>
  </div>
  <div class="GridRow__right">
    <div
      class="text-end fw-bold"
      :class="{ 'text-credit': reconciliation.differenceAmount > 0, 'text-debit': reconciliation.differenceAmount < 0 }"
    >
      {{ formatMoney(reconciliation.differenceAmount) }}
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { formatDate, formatDateTime } from '~/utils/DateUtils.js';


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
      formatDateTime,
      formatMoney,
    };
  }
};
</script>
