<template>
  <PageHeader :title="t('title')" />

  <BudgetsList />

  <BudgetForm />
</template>

<script>
import I18n from '~/utils/I18n.js';
import useBudgetStore from '~/stores/BudgetStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import BudgetsList from '~/components/budgets/BudgetsList.vue';
import BudgetForm from '~/components/budgets/BudgetForm.vue';

export default {
  components: {
    BudgetsList,
    BudgetForm,
    PageHeader,
  },

  props: {
    budgets: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.budgets.index');

    // Load props into budgets store
    const budgetStore = useBudgetStore();
    budgetStore.loadCollectionFromProps(props.budgets);

    const categoryStore = useCategoryStore();
    categoryStore.fetchCollection();

    return {
      t,
    };
  },
};
</script>
