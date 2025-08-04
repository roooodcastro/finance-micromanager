<template>
  <div
    class="GridRow__left ps-4 py-3 py-lg-0"
    :class="{
      'bg-foreground': !massEditSelected,
      'bg-primary-subtle': massEditSelected,
    }"
  >
    <div class="d-flex gap-2 align-items-center pe-lg-2">
      <input
        v-if="massEditMode"
        type="checkbox"
        :checked="massEditSelected"
        class="me-2"
      >
      <TransactionFromAutomationIndicator v-if="!!transaction.transactionAutomationId" />
      <span>{{ transaction.name }}</span>
    </div>

    <div class="d-flex align-items-center pe-lg-2">
      <CategoryBadge
        :category="transaction.category"
        :subcategory="transaction.subcategory"
      />
    </div>
  </div>

  <div
    class="GridRow__right py-3 py-lg-2"
    :class="{
      'bg-foreground': !massEditSelected,
      'bg-primary-subtle': massEditSelected,
    }"
  >
    <div class="d-none d-lg-block pe-lg-2 text-center">
      {{ formatDate(new Date(transaction.transactionDate)) }}
    </div>

    <div class="d-none d-lg-block pe-lg-2">
      <WalletBadge :wallet="transaction.wallet" />
    </div>

    <div
      class="TransactionTableRow__amount pe-lg-2 text-end"
      :class="{ 'text-credit': isCredit, 'text-debit': isDebit }"
    >
      {{ formatMoney(transaction.amount) }}
    </div>

    <div class="d-lg-none fs-5 mt-2">
      {{ transaction.wallet.name }} |
      {{ formatDate(new Date(transaction.transactionDate)) }}
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import { formatDate } from '~/utils/DateUtils.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import useTransactionStore from '~/stores/TransactionStore.js';

import TransactionFromAutomationIndicator from '~/components/transactions/TransactionFromAutomationIndicator.vue';
import CategoryBadge from '~/components/categories/CategoryBadge.vue';
import WalletBadge from '~/components/wallets/WalletBadge.vue';

export default {
  components: {
    CategoryBadge,
    TransactionFromAutomationIndicator,
    WalletBadge,
  },

  props: {
    transaction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const transactionStore = useTransactionStore();

    const { massEditMode, massEditTransactionIds } = storeToRefs(transactionStore);

    const isDebit = computed(() => props.transaction.amount < 0);
    const isCredit = computed(() => props.transaction.amount > 0);
    const massEditSelected = computed(() => massEditTransactionIds.value[props.transaction.id]);

    return {
      isDebit,
      isCredit,
      massEditMode,
      massEditSelected,
      formatMoney,
      formatDate,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(lg) {
  .TransactionTableRow__amount {
    font-size: 1.1rem !important;
  }

  .GridRow__left {
    place-content: space-between;
  }
}
</style>
