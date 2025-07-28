<template>
  <PageHeader :title="t('title')" />

  <ProfileBudget />

  <BCard
    :title="t('categories_subheader')"
    class="mt-3"
    no-body
  >
    <BudgetsList />
  </BCard>

  <BudgetForm />
</template>

<script>
import useBudgetStore from '~/stores/BudgetStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import I18n from '~/utils/I18n.js';
import { onProfileChanged } from '~/utils/OnProfileChangeWatcher.js';

import BCard from '~/components/bootstrap/BCard.vue';
import BudgetForm from '~/components/budgets/BudgetForm.vue';
import BudgetsList from '~/components/budgets/BudgetsList.vue';
import ProfileBudget from '~/components/budgets/ProfileBudget.vue';
import PageHeader from '~/components/layout/PageHeader.vue';

export default {
  components: {
    BCard,
    BudgetsList,
    BudgetForm,
    PageHeader,
    ProfileBudget,
  },

  props: {
    budgets: {
      type: Array,
      required: true,
    },
    profileBudget: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.budgets.index');

    // Load props into budgets store
    const budgetStore = useBudgetStore();
    budgetStore.loadCollectionFromProps(props.budgets);
    budgetStore.loadProfileBudgetFromProps(props.profileBudget);

    const categoryStore = useCategoryStore();
    categoryStore.fetchCollection();

    onProfileChanged(() => {
      categoryStore.fetchCollection();
      budgetStore.fetchCollection();
      budgetStore.fetchProfileBudget();
    });

    return {
      t,
    };
  },
};
</script>
