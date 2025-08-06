<template>
  <div
    class="GridRow__left ps-4 py-3"
    :class="{
      'bg-foreground': !massEditSelected,
      'bg-primary-subtle': massEditSelected,
      'GridRow__left--mobile': forcedMobile,
      'py-lg-0': !forcedMobile
    }"
  >
    <div
      class="d-flex gap-2 align-items-center"
      :class="{ 'pe-lg-2': !forcedMobile }"
    >
      <input
        v-if="massEditMode"
        type="checkbox"
        :checked="massEditSelected"
        class="me-2"
      >
      <TransactionFromAutomationIndicator v-if="!!transaction.transactionAutomationId" />
      <span>{{ transaction.name }}</span>
    </div>

    <div
      class="d-flex align-items-center"
      :class="{ 'pe-lg-2': !forcedMobile }"
    >
      <CategoryBadge
        :category="transaction.category"
        :subcategory="transaction.subcategory"
      />
    </div>
  </div>

  <div
    class="GridRow__right py-3"
    :class="{
      'bg-foreground': !massEditSelected,
      'bg-primary-subtle': massEditSelected,
      'pe-lg-2': !forcedMobile
    }"
  >
    <div
      class="d-none"
      :class="{ 'd-lg-block pe-lg-2': !forcedMobile }"
    >
      {{ formatDate(new Date(transaction.transactionDate)) }}
    </div>

    <div
      class="d-none"
      :class="{ 'd-lg-block pe-lg-2': !forcedMobile }"
    >
      <WalletBadge :wallet="transaction.wallet" />
    </div>

    <div
      class="TransactionTableRow__amount text-end"
      :class="{
        'text-credit': isCredit,
        'text-debit': isDebit,
        'TransactionTableRow__amount--mobile pe-lg-2': forcedMobile
      }"
    >
      {{ formatMoney(transaction.amount) }}
    </div>

    <div
      class="fs-5 mt-2"
      :class="{ 'd-lg-none': !forcedMobile }"
    >
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
    forcedMobile: {
      type: Boolean,
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

.TransactionTableRow__amount--mobile {
  font-size: 1.1rem !important;
}

.GridRow__left--mobile {
  place-content: space-between;
}
</style>
