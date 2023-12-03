<template>
  <div>
    <PageHeader :page-title="t('edit_title')" />

    <div class="row justify-content-center">
      <div class="col col-md-8 col-lg-6 col-xl-4">
        <TransactionForm :transaction="transaction" />
      </div>
    </div>
  </div>
</template>

<script>
import { transactions } from '~/api';
import I18n from '~/utils/I18n';
import useCategoryStore from '~/stores/CategoryStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionForm from '~/components/transactions/TransactionForm.vue';

export default {
  components: {
    PageHeader,
    TransactionForm,
  },

  props: {
    transaction: {
      type: Object,
      required: true,
    },
    categories: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const listTransactionsPath = transactions.index.path();

    useCategoryStore().loadCategoriesFromProps(props.categories);

    return {
      listTransactionsPath,
      t: I18n.scopedTranslator('views.transactions.form'),
    };
  },
};
</script>
