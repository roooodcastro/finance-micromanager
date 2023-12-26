<template>
  <ListItemDrawerContextMenu
    class="TransactionListItem__container mx-0"
    :locked="massEditMode"
  >
    <template v-slot:actions>
      <TransactionActions
        :transaction="transaction"
        :compact="compact"
        drawer-menu
      />
    </template>

    <template v-slot:item>
      <div
        class="TransactionListItem d-flex align-items-center border border-start-0 pe-2 pe-lg-0"
        :class="{
          'bg-light-subtle bg-hover-light': !massEditSelected,
          'bg-primary-subtle': massEditSelected,
        }"
        @click="handleClick"
      >
        <span
          class="TransactionListItem__indicator me-2"
          :style="{ 'background-color': transaction.category.color }"
        />
        <input
          v-if="massEditMode"
          type="checkbox"
          :checked="massEditSelected"
          class="me-2"
        >
        <div
          class="TransactionListItem__name flex-grow-1 py-2"
          :class="{ 'pe-lg-2': massEditMode }"
        >
          <div class="d-flex justify-content-between">
            <span>{{ transaction.name }}</span>
            <span
              class="TransactionListItem__amount text-end fw-bold"
              :class="{ 'text-credit': isCredit, 'text-debit': isDebit }"
            >
              {{ formatMoney(transaction.amount, transaction.amountCurrency) }}
            </span>
          </div>
          <div class="fs-6 text-muted d-flex justify-content-between">
            <span>{{ transaction.subcategory?.displayName ?? transaction.category.name }}</span>
            <span>
              {{ transaction.wallet ? `${transaction.wallet.name} |` : '' }}
              {{ formatDate(new Date(transaction.transactionDate)) }}
            </span>
          </div>
        </div>
        <div class="d-none d-lg-flex">
          <TransactionActions
            v-if="!massEditMode"
            :transaction="transaction"
            :compact="compact"
          />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import { computed } from 'vue';

import { formatDate } from '~/utils/DateUtils.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

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
    compact: {
      type: Boolean,
      default: false,
    },
    massEditMode: {
      type: Boolean,
      default: false,
    },
    massEditSelected: {
      type: Boolean,
      default: false,
    },
  },

  emits: ['mass-edit-toggle'],

  setup(props, { emit }) {
    const isDebit = computed(() => props.transaction.amount < 0);
    const isCredit = computed(() => props.transaction.amount > 0);

    const handleClick = () => {
      if (props.massEditMode) {
        emit('mass-edit-toggle', props.transaction.id);
      }
    };

    return {
      formatMoney,
      formatDate,
      isDebit,
      isCredit,
      handleClick,
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
