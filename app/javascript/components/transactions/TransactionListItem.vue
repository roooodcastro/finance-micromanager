<template>
  <ListItemDrawerContextMenu class="TransactionListItem__container mx-0">
    <template v-slot:actions>
      <TransactionActions
        :transaction="transaction"
        :show-delete="showDeleteButton"
        drawer-menu
      />
    </template>

    <template v-slot:item>
      <div class="TransactionListItem d-flex bg-light-subtle align-items-center border border-start-0 pe-2">
        <span
          class="TransactionListItem__indicator me-2"
          :style="{ 'background-color': transaction.category.color }"
        />
        <div class="TransactionListItem__name flex-grow-1 py-2">
          {{ transaction.name }}
          <div class="fs-6 text-muted">
            {{ showDate ? formatDate(new Date(transaction.transactionDate)) : transaction.category.name }}
          </div>
        </div>
        <div
          class="TransactionListItem__amount text-end fw-bold"
          :class="{ 'text-credit': isCredit, 'text-debit': isDebit }"
        >
          {{ transaction.amountWithUnit }}
        </div>
        <div class="d-none d-lg-flex">
          <TransactionActions
            :transaction="transaction"
            :show-delete="showDeleteButton"
          />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import { formatDate } from '~/utils/DateUtils';
import { parseLocaleNumber } from '~/utils/NumberFormatter.js';

import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';
import TransactionActions from '~/components/transactions/TransactionActions.vue';

export default {
  components: {
    ListItemDrawerContextMenu,
    TransactionActions,
  },

  props: {
    transaction: {
      type: Object,
      required: true,
    },
    showDate: {
      type: Boolean,
      default: false,
    },
    showDeleteButton: {
      type: Boolean,
      default: true,
    },
  },

  setup(props) {
    const isDebit = parseLocaleNumber(props.transaction.amount) < 0;
    const isCredit = parseLocaleNumber(props.transaction.amount) > 0;
    return {
      formatDate,
      isDebit,
      isCredit,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.TransactionListItem {
  border-left: 0.5em solid white;

  .credit-transaction {
    color: $mintgreen-700;
  }

  .debit-transaction {
    color: $red;
  }
}

.TransactionListItem__container:first-child .TransactionListItem {
  border-top: none !important;
}

.TransactionListItem__container:not(:first-child) .TransactionListItem {
  margin-top: -1px;
}

.TransactionListItem__indicator {
  width: 0.5rem;
  align-self: stretch;
  display: block;
}
</style>
