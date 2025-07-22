<template>
  <PageHeader
    :title="budgetFromStore.ownerName"
    :sub-title="t('title')"
    :back-button-href="budgetsPath"
  >
    <template v-slot:actions>
      <DropdownMenuItem
        v-if="!isDisabled"
        :label="t('edit')"
        icon="pen-to-square"
        @click="handleEdit"
      />

      <DropdownMenuItem
        v-if="!isDisabled"
        :label="t('disable')"
        icon="ban"
        class="text-bg-danger"
        @click="handleDisable"
      />

      <DropdownMenuItem
        v-else
        :label="t('reenable')"
        icon="repeat"
        class="text-bg-success"
        @click="handleReenable"
      />
    </template>
  </PageHeader>

  <DateRangeSelector
    class="mb-3"
    @change="handleDateRangeChange"
  />

  <div class="row">
    <div class="col-12 col-xl-6 mb-3">
      <BudgetSummary
        :budget="budgetFromStore"
        :budget-instance="budgetInstance"
        :loading="loadingBudgets"
      />
    </div>

    <div class="col-12 col-xl-6 mb-3">
      <BCard :title="t('sub_header_budget_history')">
        <BudgetHistoryChart />
      </BCard>
    </div>
  </div>

  <BudgetForm />
</template>

<script>
import { storeToRefs } from 'pinia';
import { computed, watch } from 'vue';

import { budgets as budgetsApi } from '~/api/all.js';
import useBudgetInstanceStore from '~/stores/BudgetInstanceStore.js';
import useBudgetStore from '~/stores/BudgetStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import I18n from '~/utils/I18n.js';

import BCard from '~/components/bootstrap/BCard.vue';
import BudgetForm from '~/components/budgets/BudgetForm.vue';
import BudgetHistoryChart from '~/components/budgets/BudgetHistoryChart.vue';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';
import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import BudgetSummary from '~/components/budgets/BudgetSummary.vue';

export default {
  components: {
    BCard,
    BudgetForm,
    BudgetHistoryChart,
    BudgetSummary,
    DateRangeSelector,
    DropdownMenuItem,
    PageHeader,
  },

  props: {
    budget: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.budgets.show');
    const budgetsPath = budgetsApi.index.path();

    const dateRangeStore = useDateRangeStore();
    const budgetInstanceStore = useBudgetInstanceStore();
    const budgetStore = useBudgetStore();
    const transactionStore = useTransactionStore();

    // Load budget from props
    const { budget: budgetFromStore } = storeToRefs(budgetStore);
    budgetFromStore.value = props.budget;
    const isDisabled = computed(() => !!budgetFromStore.value.disabledAt);

    const { transactions } = storeToRefs(transactionStore);
    const { startDate, endDate } = storeToRefs(dateRangeStore);
    const { budgetInstances, loading: loadingBudgets } = storeToRefs(budgetInstanceStore);
    const { budgets } = storeToRefs(budgetStore);

    const budgetInstance = computed(() => budgetInstances.value.find(bi => bi.ownerId === props.budget.ownerId));

    budgetStore.fetchCollection();
    budgetInstanceStore.setFetchParams({ startDate, endDate });
    budgetInstanceStore.fetchCollection();
    budgetInstanceStore.fetchForHistory(props.budget.ownerId, endDate.value);

    // If profile changes, redirect back to the budgets index page, as the current budget is for another profile
    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => window.location.href = budgetsApi.index.path());

    watch(transactions, () => {
      budgetStore.fetchSingle(props.budget.id);
      budgetInstanceStore.fetchCollection();
      budgetInstanceStore.fetchForHistory(props.budget.ownerId, endDate.value);
    });
    watch(budgets, (newBudgets, oldBudgets) => {
      if (newBudgets?.length > 0 && oldBudgets?.length === 0) {
        return;
      }

      budgetInstanceStore.fetchCollection();
      budgetInstanceStore.fetchForHistory(props.budget.ownerId, endDate.value);
    });

    const handleEdit = () => budgetStore.openFormModal(props.budget.id);
    const handleDisable = () => budgetStore.disable(props.budget.id, { fetchSingle: true });
    const handleReenable = () => budgetStore.reenable(props.budget.id, { fetchSingle: true });
    const handleDateRangeChange = () => {
      budgetInstanceStore.setFetchParams({ startDate, endDate });
      budgetInstanceStore.fetchCollection();
      budgetInstanceStore.fetchForHistory(props.budget.ownerId, endDate.value);
    };

    return {
      t,
      budgetsPath,
      budgetFromStore,
      budgetInstance,
      isDisabled,
      loadingBudgets,
      handleEdit,
      handleDisable,
      handleReenable,
      handleDateRangeChange,
    };
  },
};
</script>
