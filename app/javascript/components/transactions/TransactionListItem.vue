<template>
  <ListItemDrawerContextMenu class="mx-2 mx-lg-0">
    <template v-slot:actions>
      <EditButton
        :href="editTransactionPath(transaction.id)"
        class="TransactionListItem__actionButton h-100 d-flex align-items-center justify-content-center bg-secondary text-white"
      />

      <DeleteButton
        href="#"
        class="TransactionListItem__actionButton h-100 d-flex align-items-center justify-content-center bg-danger text-white"
        @delete="handleDelete(transaction.id)"
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
            {{ transaction.category.name }}
          </div>
        </div>
        <div
          class="TransactionListItem__amount text-end fw-bold"
          :class="{ 'credit-transaction': transaction.amount >= 0, 'debit-transaction': transaction.amount < 0 }"
        >
          {{ transaction.amountWithUnit }}
        </div>
        <div class="d-none d-lg-flex">
            <div class="vr mx-3"></div>

            <EditButton
              :href="editTransactionPath(transaction.id)"
            />

            <DeleteButton
              href="#"
              class="ms-3"
              @delete="handleDelete(transaction.id)"
            />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import { transactions as transactionsApi } from '~/api';
import useNotificationStore from '~/stores/NotificationStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';

import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';
import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
    DeleteButton,
    EditButton,
    ListItemDrawerContextMenu,
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
