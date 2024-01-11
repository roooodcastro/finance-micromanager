<template>
  <ListItemDrawerContextMenu class="list-group-item p-0 overflow-hidden">
    <template v-slot:actions>
      <TransactionAutomationActions
        :transaction-automation="transactionAutomation"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div
        class="d-flex align-items-center py-2 ps-4 pe-2 pe-lg-0 side-strip"
        :class="{ 'side-strip-danger': isDisabled, 'side-strip-primary': !isDisabled }"
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
            <span>
              {{ t('schedule_desc', { interval: transactionAutomation.scheduleInterval }) }}
              {{ I18n.t(`activerecord.attributes.transaction_automation.schedule_types.${transactionAutomation.scheduleTypeKey}`) }}
            </span>
            <span>
              {{ transactionAutomation.transactionSubcategory?.displayName ?? transactionAutomation.transactionCategory.name }}
            </span>
          </div>

          <div class="fs-6 text-muted d-flex justify-content-between">
            <span>
              {{ t('next_run_desc', { date: formatDate(transactionAutomation.nextScheduleDate) }) }}
            </span>
            <span>
              {{ transactionAutomation.transactionWallet?.name }}
            </span>
          </div>
        </div>

        <div class="d-none d-lg-flex ms-auto pe-2 flex-shrink-0">
          <TransactionAutomationActions :transaction-automation="transactionAutomation" />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

import TransactionAutomationActions from '~/components/transaction_automations/TransactionAutomationActions.vue';
import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';

export default {
  components: {
    ListItemDrawerContextMenu,
    TransactionAutomationActions,
  },

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

    return {
      I18n,
      t,
      isDisabled,
      isDebit,
      isCredit,
      formatDate,
      formatMoney,
    };
  }
};
</script>
