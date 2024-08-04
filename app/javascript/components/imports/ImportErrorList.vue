<template>
  <NoRecordsFound v-if="!errorTransactions.length" />
  <div
    v-else
    class="WalletsList list-group overflow-x-hidden"
  >
    <template
      v-for="errorTransaction in errorTransactions"
      :key="errorTransaction.importTransaction.id"
    >
      <ImportErrorListItem :error-transaction="errorTransaction" />
    </template>
  </div>
</template>

<script>
import ImportErrorListItem from '~/components/imports/ImportErrorListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    ImportErrorListItem,
    NoRecordsFound,
  },

  props: {
    errorTransactions: {
      type: Array,
      required: true,
    },
  },
};
</script>
