<template>
  <table class="table align-middle bg-white">
    <thead class="table-light">
      <tr>
        <th>{{ t('transaction_date') }}</th>
        <th>{{ t('name') }}</th>
        <th>{{ t('category') }}</th>
        <th></th>
      </tr>
    </thead>
    <tbody class="table-group-divider">
      <tr
        v-for="transaction in transactions"
        :key="transaction.id"
      >
        <td>{{ formatDate(transaction.transactionDate) }}</td>
        <td>{{ transaction.name }}</td>
        <td>{{ transaction.category.name }}</td>
        <td>
          <a
            :href="editTransactionPath(transaction.id)"
            class="btn btn-outline-secondary btn-sm"
          >
            {{ t('edit') }}
          </a>

          <a
            :href="destroyTransactionPath(transaction.id)"
            data-method="DELETE"
            :data-confirm="t('delete_confirmation')"
            class="btn btn-outline-danger btn-sm ms-2"
          >
            {{ t('delete') }}
          </a>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { transactions } from '~/api';
import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils';

export default {
  props: {
    transactions: {
      type: Array,
      required: true,
    },
  },

  setup() {
    const editTransactionPath = (transactionId) => transactions.edit.path({ id: transactionId });
    const destroyTransactionPath = (transactionId) => transactions.destroy.path({ id: transactionId });

    return {
      formatDate,
      editTransactionPath,
      destroyTransactionPath,
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>
