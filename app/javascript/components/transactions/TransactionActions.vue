<template>
  <div class="vr mx-3 d-none d-lg-flex" />

  <EditButton
    v-if="showEdit"
    href="#"
    :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
    @click="handleEdit"
  />

  <DeleteButton
    v-if="showDelete"
    href="#"
    :class="{
      'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
      'ms-3': !drawerMenu,
    }"
    @delete="handleDelete(transaction.id)"
  />
</template>
<script>
import { transactions as transactionsApi } from '~/api/all.js';
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
    drawerMenu: {
      type: Boolean,
      default: false,
    },
    showEdit: {
      type: Boolean,
      default: true,
    },
    showDelete: {
      type: Boolean,
      default: true,
    },
  },

  setup(props) {
    const notificationStore = useNotificationStore();
    const transactionStore = useTransactionStore();

    const handleEdit = () => transactionStore.openFormModal(props.transaction.id);

    const handleDelete = (id) => {
      transactionsApi.destroy({ id }).then((response) => {
        notificationStore.notify(response.message, 'success');
        transactionStore.remove(response.transactionId);
      });
    };

    return {
      handleEdit,
      handleDelete,
    };
  }
};
</script>
