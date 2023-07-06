<template>
  <div>
    <TransactionsFilter @change="handleFiltersChange" />

    <table class="table align-middle bg-white">
      <thead class="table-light">
        <tr>
          <th>{{ t('name') }}</th>
          <th>{{ t('category') }}</th>
          <th class="text-end">
            {{ t('amount') }}
          </th>
          <th></th>
        </tr>
      </thead>
      <tbody class="table-group-divider">
        <template
          v-for="(transactionsByDate, transactionDate) in groupedTransactions"
          :key="transactionDate"
        >
          <tr class="TransactionsList__date-row fw-bold bg-light-primary border-0">
            <td colspan="4">
              {{ formatDate(new Date(transactionDate)) }}
            </td>
          </tr>
          <tr
            v-for="transaction in transactionsByDate"
            :key="transaction.id"
          >
            <td>{{ transaction.name }}</td>
            <td>
              <CategoryIndicator :category="transaction.category" />
            </td>
            <td class="text-end">
              {{ transaction.amountWithUnit }}
            </td>
            <td class="text-end">
              <EditButton
                small
                :href="editTransactionPath(transaction.id)"
              />

              <DeleteButton
                small
                :href="destroyTransactionPath(transaction.id)"
                class="ms-3"
              />
            </td>
          </tr>
        </template>
      </tbody>
    </table>
  </div>
</template>

<script>
import { watch, toRef } from 'vue';
import { storeToRefs } from 'pinia';

import { transactions as transactionsApi } from '~/api';
import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useAccountStore from '~/stores/AccountStore.js';

import TransactionsFilter from '~/components/transactions/TransactionsFilter.vue';
import CategoryIndicator from '~/components/categories/CategoryIndicator.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';
import EditButton from '~/components/rails/EditButton.vue';

export default {
  components: {
    CategoryIndicator,
    DeleteButton,
    EditButton,
    TransactionsFilter,
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
    const { transactions: transactionsFromStore, groupedTransactions } = storeToRefs(transactionStore);
    transactionsFromStore.value = toRef(props.transactions).value;

    const handleFiltersChange = () => transactionStore.fetchTransactions();

    // Reload transactions if account has changed while this page is open
    const accountStore = useAccountStore();
    watch(
      () => accountStore.currentAccount,
      () => transactionStore.fetchTransactions(),
    );

    return {
      formatDate,
      editTransactionPath,
      destroyTransactionPath,
      transactionsFromStore,
      groupedTransactions,
      handleFiltersChange,
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>
