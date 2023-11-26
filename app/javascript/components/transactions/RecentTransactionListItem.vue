<template>
  <ListItemDrawerContextMenu class="TransactionListItem__container">
    <template v-slot:actions>
      <TransactionActions
        :transaction="transaction"
        drawer-menu
        :show-delete="false"
      />
    </template>

    <template v-slot:item>
      <div class="TransactionListItem d-flex bg-light-subtle align-items-center border-top border-start-0 pe-3">
        <span
          class="TransactionListItem__indicator me-2"
          :style="{ 'background-color': transaction.category.color }"
        />
        <div class="TransactionListItem__name flex-grow-1 py-2">
          {{ transaction.name }}
          <div class="fs-6 text-muted">
            {{ formatDate(new Date(transaction.transactionDate)) }}
          </div>
        </div>
        <div
          class="TransactionListItem__amount text-end fw-bold"
          :class="{ 'credit-transaction': transaction.amount >= 0, 'debit-transaction': transaction.amount < 0 }"
        >
          {{ transaction.amountWithUnit }}
        </div>
        <div class="d-none d-lg-flex">
          <TransactionActions
            :transaction="transaction"
            :show-delete="false"
          />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import { formatDate } from '~/utils/DateUtils.js';

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
  },

  setup() {
    return { formatDate };
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
