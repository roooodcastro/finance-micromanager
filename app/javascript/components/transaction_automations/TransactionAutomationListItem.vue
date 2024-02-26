<template>
  <ListItem
    :record="transactionAutomation"
    :actions-component="TransactionAutomationActions"
  >
    <a
      class="text-decoration-none text-body list-group-item-action d-flex align-items-center p-2 ps-4 min-width-0 side-strip"
      :class="{ 'side-strip-danger': isDisabled, 'side-strip-primary': !isDisabled }"
      :href="showTransactionAutomationPath(transactionAutomation.id)"
    >
      <div class="flex-grow-1">
        <div class="d-flex justify-content-between">
          <span class="d-flex align-items-center">
            <span :class="{ 'text-muted': isDisabled }">
              {{ transactionAutomation.transactionName }}
            </span>
            <span
              v-if="isDisabled"
              class="badge text-bg-danger ms-2"
            >
              {{ t('disabled') }}
            </span>
          </span>

          <span
            class="text-end fw-bold"
            :class="{ 'text-muted': isDisabled, 'text-credit': isCredit && !isDisabled, 'text-debit': isDebit && !isDisabled }"
          >
            {{ formatMoney(transactionAutomation.transactionAmount) }}
          </span>
        </div>

        <div class="fs-6 mt-1 text-muted d-flex justify-content-between">
          <span v-if="isCustomRule">
            {{ t('schedule_desc', { interval: I18n.t(`activerecord.attributes.transaction_automation.schedule_custom_rule.${transactionAutomation.scheduleCustomRule}`) }) }}
          </span>
          <span v-else>
            {{ t('schedule_desc', { interval: transactionAutomation.scheduleInterval }) }}
            {{ I18n.t(`activerecord.attributes.transaction_automation.schedule_types.${transactionAutomation.scheduleTypeKey}`) }}
          </span>
          <span>
            {{ transactionAutomation.transactionSubcategory?.displayName ?? transactionAutomation.transactionCategory.name }}
          </span>
        </div>

        <div class="fs-6 text-muted d-flex justify-content-between">
          <span>
            {{ t('next_run_desc', { date: formatDate(transactionAutomation.scheduledDate) }) }}
          </span>
          <span>
            {{ transactionAutomation.transactionWallet?.name }}
          </span>
        </div>
      </div>
    </a>
  </ListItem>
</template>

<script>
import { computed, markRaw } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { transactionAutomations as transactionAutomationsApi } from '~/api/all.js';

import TransactionAutomationActions from '~/components/transaction_automations/TransactionAutomationActions.vue';
import ListItem from '~/components/ui/ListItem.vue';

export default {
  components: { ListItem },

  props: {
    transactionAutomation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    markRaw(TransactionAutomationActions);
    const t = I18n.scopedTranslator('views.transaction_automations.list');

    const showTransactionAutomationPath = id => transactionAutomationsApi.show.path({ id });

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
      showTransactionAutomationPath,
      formatDate,
      formatMoney,
      TransactionAutomationActions,
    };
  }
};
</script>
