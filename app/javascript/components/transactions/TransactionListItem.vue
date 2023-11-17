<template>
  <div class="TransactionListItem d-flex bg-light-subtle align-items-center border border-start-0 mx-2 mx-lg-0 bg-white pe-2">
    <span
      class="TransactionListItem__indicator me-2"
      :style="{ 'background-color': transaction.category.color }"
    />
    <div class="TransactionListItem__name flex-grow-1 py-2">
      {{ transaction.name }}
      <div class="fs-6 text-muted">
        {{ transaction.category.name }}
      </div>
    </div>
    <div class="TransactionListItem__amount text-end">
      {{ transaction.amountWithUnit }}
    </div>
    <div class="text-end">
      <EditButton
        small
        :href="editTransactionPath(transaction.id)"
        class="ms-3"
      />

      <DeleteButton
        small
        :href="destroyTransactionPath(transaction.id)"
        class="ms-2"
      />
    </div>
  </div>
</template>

<script>
import { transactions as transactionsApi } from '~/api';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
    DeleteButton,
    EditButton,
  },

  props: {
    transaction: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const editTransactionPath = (transactionId) => transactionsApi.edit.path({ id: transactionId });
    const destroyTransactionPath = (transactionId) => transactionsApi.destroy.path({ id: transactionId });

    return {
      editTransactionPath,
      destroyTransactionPath,
    };
  }
};
</script>

<style lang="scss" scoped>
.TransactionListItem {
  border-left: 0.5em solid white;
}

.TransactionListItem:not(:first-child) {
  margin-top: -1px;
}

.TransactionListItem__indicator {
  width: 0.5rem;
  align-self: stretch;
  display: block;
}
</style>
