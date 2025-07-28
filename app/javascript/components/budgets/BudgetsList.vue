<template>
  <NoRecordsFound v-if="!categoriesWithBudgets.length" />
  <template v-else>
    <GridTable
      :columns="budgetColumns"
      :rows="categoriesWithBudgets"
      :actions="categoryActions"
      :side-strip-color="sideStripColorFunction"
      hoverable
      bordered
      rounded
    >
      <template v-slot:default="{ row: budgetWithCategory }">
        <BudgetTableRow
          :category="budgetWithCategory.category"
          :budget="budgetWithCategory.budget"
        />
      </template>
    </GridTable>
  </template>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useBudgetStore from '~/stores/BudgetStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import { BUDGET_OWNER_TYPE_CATEGORY } from '~/utils/Constants.js';

import BudgetTableRow from '~/components/budgets/BudgetTableRow.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import GridTable from '~/components/ui/GridTable.vue';

export default {
  components: {
    BudgetTableRow,
    GridTable,
    NoRecordsFound,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.budgets_list');

    const budgetStore = useBudgetStore();
    const categoryStore = useCategoryStore();

    const { budgets } = storeToRefs(budgetStore);
    const { categories } = storeToRefs(categoryStore);

    const categoriesWithBudgets = computed(() => {
      return categories.value.map((category) => {
        const budget = budgets.value.find((budget) => {
          return budget.ownerId === category.id && budget.ownerType === BUDGET_OWNER_TYPE_CATEGORY
        }) ?? {};

        return { category, budget, href: budget.href };
      });
    });

    const categoryActions = [
      {
        label: I18n.t('views.layout.grid_table.edit_action_label'),
        icon: 'pen-to-square',
        callback: row => budgetStore.openFormModal(row.budget.id),
        variant: 'secondary',
        show: row => !!row.budget.id && !row.budget.disabledAt
      },
      {
        label: I18n.t('views.layout.grid_table.disable_action_label'),
        icon: 'ban',
        callback: row => budgetStore.disable(row.budget.id),
        variant: 'danger',
        show: row => !!row.budget.id && !row.budget.disabledAt
      },
      {
        label: I18n.t('views.layout.grid_table.reenable_action_label'),
        icon: 'repeat',
        callback: row => budgetStore.reenable(row.budget.id),
        variant: 'success',
        show: row => !!row.budget.id && !!row.budget.disabledAt
      },
      {
        label: t('new_budget_label'),
        icon: 'plus',
        callback: row => budgetStore.openFormModal(null, { ownerType: BUDGET_OWNER_TYPE_CATEGORY, ownerId: row.category.id }),
        variant: 'primary',
        show: row => !row.budget.id
      },
    ];

    const budgetColumns = [
      { label: t('category_name_label'), side: 'left' },
      { label: t('budget_usage_label'), side: 'right' },
    ];

    const sideStripColorFunction = row => row.category.color;

    return {
      categoriesWithBudgets,
      budgetColumns,
      categoryActions,
      sideStripColorFunction,
    };
  },
};
</script>
