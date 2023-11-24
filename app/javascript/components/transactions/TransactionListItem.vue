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
    <div
      class="TransactionListItem__amount text-end fw-bold"
      :class="{ 'credit-transaction': transaction.amount >= 0, 'debit-transaction': transaction.amount < 0 }"
    >
      {{ transaction.amountWithUnit }}
    </div>
    <div class="text-end ms-2">
      <EditButton
        small
        :href="editTransactionPath(transaction.id)"
        class="ms-3"
      />

      <DeleteButton
        small
        href="#"
        class="ms-2"
        @delete="handleDelete(transaction.id)"
      />
    </div>
  </div>
</template>

<script>
import { transactions as transactionsApi } from '~/api';
import useNotificationStore from '~/stores/NotificationStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';

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

    const notificationStore = useNotificationStore();
    const transactionStore = useTransactionStore();

    const handleDelete = (id) => {
      transactionsApi.destroy({ id }).then((response) => {
        notificationStore.notify(response.message, 'success');
        transactionStore.remove(response.transactionId);
      });
    };

    return {
      editTransactionPath,
      handleDelete,
    };
  }
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

.TransactionListItem:not(:first-child) {
  margin-top: -1px;
}

.TransactionListItem__indicator {
  width: 0.5rem;
  align-self: stretch;
  display: block;
}
</style>
