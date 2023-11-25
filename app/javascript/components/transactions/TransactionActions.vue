<template>
  <div class="vr mx-3 d-none d-lg-flex"></div>

  <EditButton
    :href="editTransactionPath(transaction.id)"
    :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
  />

  <DeleteButton
      href="#"
      :class="{
        'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
        'ms-3': !drawerMenu,
      }"
      @delete="handleDelete(transaction.id)"
  />
</template>
<script>
import { transactions as transactionsApi } from '~/api';
import useNotificationStore from '~/stores/NotificationStore';
import useTransactionStore from '~/stores/TransactionStore';

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
    drawerMenu: {
      type: Boolean,
      default: false,
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
