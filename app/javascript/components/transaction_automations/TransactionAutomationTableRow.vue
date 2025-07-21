<template>
  <div class="GridRow__left">
    <!-- Name column -->
    <div class="d-flex gap-2 align-items-center">
      <span :class="{ 'text-muted': isDisabled }">
        {{ transactionAutomation.transactionName }}
      </span>
      <Badge
        v-if="isDisabled"
        type="disabled"
        i18n-scope="views.transaction_automations.show.disabled"
      />
    </div>

    <!-- Category & Wallet columns -->
    <div class="GridRow__category-wallet-column">
      <span>
        {{ transactionAutomation.transactionSubcategory?.displayName ?? transactionAutomation.transactionCategory.name }}
      </span>

      <span class="d-block fs-6 text-muted">
        {{ transactionAutomation.transactionWallet?.name }}
      </span>
    </div>
  </div>

  <div class="GridRow__right">
    <!-- Schedule & Next Run columns -->
    <div class="GridRow__schedule-column">
      <span v-if="isCustomRule">
        {{ t('schedule_desc', { interval: I18n.t(`activerecord.attributes.transaction_automation.schedule_custom_rule.${transactionAutomation.scheduleCustomRule}`) }) }}
      </span>
      <span v-else>
        {{ t('schedule_desc', { interval: transactionAutomation.scheduleInterval }) }}
        {{ I18n.t(`activerecord.attributes.transaction_automation.schedule_types.${transactionAutomation.scheduleTypeKey}`) }}
      </span>

      <span class="d-block fs-6 text-muted">
        {{ t('next_run_desc', { date: formatDate(transactionAutomation.scheduledDate) }) }}
      </span>
    </div>

    <!-- Amount column -->
    <div
      class="fs-5 align-self-center text-end fw-bold"
      :class="{ 'text-muted': isDisabled, 'text-credit': isCredit && !isDisabled, 'text-debit': isDebit && !isDisabled }"
    >
      {{ formatMoney(transactionAutomation.transactionAmount) }}
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

import Badge from '~/components/ui/Badge.vue';

export default {
  components: { Badge },

  props: {
    transactionAutomation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_automations.list');

    const isDisabled = computed(() => !!props.transactionAutomation.disabledAt);
    const isDebit = computed(() => props.transactionAutomation.transactionAmount < 0);
    const isCredit = computed(() => props.transactionAutomation.transactionAmount > 0);
    const isCustomRule = computed(() => props.transactionAutomation.scheduleType === 'C');

    return {
      I18n,
      t,
      isDisabled,
      isDebit,
      isCredit,
      isCustomRule,
      formatDate,
      formatMoney,
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(lg) {
  .GridRow__schedule-column {
    color: var(--bs-secondary-color);
    font-size: $h6-font-size;
    text-align: right;
    order: 1;
  }
}
</style>
