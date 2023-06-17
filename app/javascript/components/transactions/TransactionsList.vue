<template>
  <table class="table align-middle bg-white">
    <thead class="table-light">
      <tr>
        <th>{{ t('transaction_date') }}</th>
        <th>{{ t('name') }}</th>
        <th>{{ t('category') }}</th>
        <th>{{ t('amount') }}</th>
        <th></th>
      </tr>
    </thead>
    <tbody class="table-group-divider">
      <tr
        v-for="transaction in transactionsFromStore"
        :key="transaction.id"
      >
        <td>{{ formatDate(transaction.transactionDate) }}</td>
        <td>{{ transaction.name }}</td>
        <td>
          <CategoryIndicator :category="transaction.category" />
        </td>
        <td>{{ transaction.amountWithUnit }}</td>
        <td class="text-end">
          <EditButton
            small
            :href="editTransactionPath(transaction.id)"
          />

          <DeleteButton
            small
            :href="destroyTransactionPath(transaction.id)"
            class="ms-2"
          />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { watch, toRefs } from 'vue';
import { storeToRefs } from 'pinia';

import { transactions as transactionsApi } from '~/api';
import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useAccountStore from '~/stores/AccountStore.js';

import CategoryIndicator from '~/components/categories/CategoryIndicator.vue';
import DeleteButton from '@/components/rails/DeleteButton.vue';
import EditButton from '@/components/rails/EditButton.vue';

export default {
  components: {
    CategoryIndicator,
    DeleteButton,
    EditButton,
  },

  props: {
    transactions: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const editTransactionPath = (transactionId) => transactionsApi.edit.path({ id: transactionId });
    const destroyTransactionPath = (transactionId) => transactionsApi.destroy.path({ id: transactionId });

    // Load transactions from props
    const transactionStore = useTransactionStore();
    const { transactions: transactionsFromStore } = storeToRefs(transactionStore);
    transactionsFromStore.value = toRefs(props.transactions);

    // Reload transactions if account has changed while this page is open
    const accountStore = useAccountStore();
    watch(
      () => accountStore.currentAccount,
      () => {
        transactionsApi.list().then(response => transactionsFromStore.value = response.transactions);
      },
    );

    return {
      formatDate,
      editTransactionPath,
      destroyTransactionPath,
      transactionsFromStore,
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>
