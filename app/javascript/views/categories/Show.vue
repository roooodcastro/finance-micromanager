<template>
  <PageHeader
    :sub-title="t('title')"
    :back-button-href="categoriesPath"
  >
    <div class="d-flex gap-3 align-items-center">
      {{ categoryFromStore.name }}

      <Badge
        v-if="categoryFromStore.favourite"
        type="favourite"
        i18n-scope="views.categories.show.favourite"
        class="fs-5"
      />

      <Badge
        v-if="isDisabled"
        type="disabled"
        i18n-scope="views.categories.show.disabled"
        class="fs-5"
      />
    </div>

    <template
      v-if="!categoryFromStore.system"
      v-slot:actions
    >
      <template v-if="!isDisabled">
        <DropdownMenuItem
          :label="t('new_subcategory')"
          icon="plus"
          @click="handleNewSubcategory"
        />
        <DropdownMenuItem
          :label="t('edit')"
          icon="pen-to-square"
          @click="handleEdit"
        />
        <DropdownMenuItem
          :label="t('set_budget_menu_item')"
          :icon="ICON_BUDGETS"
          @click="handleSetBudget"
        />
        <DropdownMenuItem
          v-if="!categoryFromStore.favourite"
          :label="t('set_favourite_menu_item')"
          icon="star"
          @click="handleToggleFavourite"
        />
        <DropdownMenuItem
          v-if="categoryFromStore.favourite"
          :label="t('remove_favourite_menu_item')"
          :icon="['far', 'star']"
          @click="handleToggleFavourite"
        />

        <hr class="my-2">

        <DropdownMenuItem
          v-if="!isDisabled"
          :label="t('disable')"
          icon="ban"
          class="text-bg-danger"
          @click="handleDisable"
        />
      </template>
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

  <WarningAlert
    v-if="isDisabled"
    :message="t('disabled_category_warning')"
  />

  <TabRowContainer
    :tabs="tabsConfig"
    no-card-when-expanded
  >
    <template v-slot:summary="{ isTabLayout }">
      <CategorySummaryCard
        :category="categoryFromStore"
        :loading="loadingCategory"
        :no-card="isTabLayout"
      />

      <SubcategoriesCard
        :no-card="isTabLayout"
        class="mt-md-3"
      />

      <template v-if="!isTabLayout && !!budgetInstance">
        <CategoryBudgetSummaryCard
          :category="categoryFromStore"
          class="mt-md-3"
        />
      </template>
    </template>

    <template v-slot:transactions="{ isTabLayout }">
      <TransactionsCard :no-card="isTabLayout" />
    </template>

    <template v-slot:budget="{ isTabLayout }">
      <CategoryBudgetSummaryCard
        v-if="isTabLayout"
        :category="categoryFromStore"
        no-card
      />
    </template>
  </TabRowContainer>

  <SubcategoryForm :category="categoryFromStore" />
  <CategoryForm />
  <BudgetForm />
</template>

<script>
import { storeToRefs } from 'pinia';
import { computed, watch } from 'vue';

import { categories as categoriesApi } from '~/api/all.js';
import useBudgetInstanceStore from '~/stores/BudgetInstanceStore.js';
import useBudgetStore from '~/stores/BudgetStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import {
  BUDGET_OWNER_TYPE_CATEGORY,
  ICON_BUDGETS,
  ICON_CATEGORIES,
} from '~/utils/Constants.js';
import I18n from '~/utils/I18n.js';

import WarningAlert from '~/components/bootstrap/WarningAlert.vue';
import BudgetForm from '~/components/budgets/BudgetForm.vue';
import CategoryForm from '~/components/categories/CategoryForm.vue';
import CategorySummaryCard from '~/components/categories/CategorySummaryCard.vue';
import SubcategoriesCard from '~/components/categories/SubcategoriesCard.vue';
import CategoryBudgetSummaryCard from '~/components/categories/CategoryBudgetSummaryCard.vue';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';
import PageHeader from '~/components/layout/PageHeader.vue';
import SubcategoryForm from '~/components/subcategories/SubcategoryForm.vue';
import TransactionsCard from '~/components/categories/TransactionsCard.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import TabRowContainer from '~/components/layout/TabRowContainer.vue';
import Badge from '~/components/ui/Badge.vue';

export default {
  components: {
    BudgetForm,
    CategoryBudgetSummaryCard,
    CategoryForm,
    CategorySummaryCard,
    DateRangeSelector,
    DropdownMenuItem,
    Badge,
    PageHeader,
    SubcategoriesCard,
    SubcategoryForm,
    TabRowContainer,
    TransactionsCard,
    WarningAlert,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.categories.show');
    const categoriesPath = categoriesApi.index.path();

    const tabsConfig = computed(() => {
      const tabs = [
        { slot: 'summary', noBodyOnCard: true, title: t('sub_header_summary'), colClasses: 'col-6 mb-3' },
        {
          slot: 'transactions',
          noBodyOnCard: true,
          title: t('sub_header_recent_transactions'),
          colClasses: 'col-6 mb-3'
        },
      ];

      if (budgetInstance.value) {
        tabs.splice(2, 0, { slot: 'budget', title: t('sub_header_budget'), colClasses: 'col-6 mb-3' });
      }

      return tabs;
    });

    const categoryStore = useCategoryStore();
    const subcategoryStore = useSubcategoryStore();
    const transactionStore = useTransactionStore();
    const dateRangeStore = useDateRangeStore();
    const budgetInstanceStore = useBudgetInstanceStore();
    const budgetStore = useBudgetStore();
    const floatingActionButtonStore = useFloatingActionButtonStore();

    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.categories.floating_button_label'),
      icon: ICON_CATEGORIES,
      callback: () => categoryStore.openFormModal(null),
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    const { transactions } = storeToRefs(transactionStore);
    const { startDate, endDate } = storeToRefs(dateRangeStore);
    const { budgetInstanceForCategory } = storeToRefs(budgetInstanceStore);
    const { budgets } = storeToRefs(budgetStore);

    // Load categories from props
    const { category: categoryFromStore, loading: loadingCategory } = storeToRefs(categoryStore);
    categoryFromStore.value = props.category;

    const isDisabled = computed(() => !!categoryFromStore.value.disabledAt);
    const budgetInstance = computed(() => budgetInstanceForCategory.value(props.category.id));

    transactionStore.setFetchParams({ categoryIds: props.category.id, daysToShow: 0 });
    transactionStore.fetchCollection();

    budgetStore.fetchCollection();
    budgetInstanceStore.setFetchParams({ startDate, endDate });
    budgetInstanceStore.fetchCollection();
    budgetInstanceStore.fetchForHistory(props.category.id, endDate.value);

    // Load subcategories from props
    const {
      categoryId: subcategoryCategoryId,
      subcategories: subcategoriesFromStore,
    } = storeToRefs(subcategoryStore);
    subcategoriesFromStore.value = props.category.subcategories;
    subcategoryCategoryId.value = props.category.id;

    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => window.location.href = categoriesApi.index.path());

    watch(subcategoriesFromStore, () => { categoryStore.fetchSingle(props.category.id) });
    watch(transactions, () => {
      categoryStore.fetchSingle(props.category.id);
      budgetInstanceStore.fetchCollection();
      budgetInstanceStore.fetchForHistory(props.category.id, endDate.value);
    });
    watch(budgets, () => {
      budgetInstanceStore.fetchCollection();
      budgetInstanceStore.fetchForHistory(props.category.id, endDate.value);
    });

    const handleEdit = () => categoryStore.openFormModal(props.category.id);
    const handleDisable = () => categoryStore.disable(props.category.id, { fetchSingle: true });
    const handleReenable = () => categoryStore.reenable(props.category.id, { fetchSingle: true });
    const handleNewSubcategory = () => subcategoryStore.openFormModal(null);
    const handleDateRangeChange = () => {
      categoryStore.fetchSingle(props.category.id);
      transactionStore.fetchCollection();
      budgetInstanceStore.setFetchParams({ startDate, endDate });
      budgetInstanceStore.fetchCollection();
      budgetInstanceStore.fetchForHistory(props.category.id, endDate.value);
    };

    const handleSetBudget = () => {
      budgetStore.openFormModal(
        budgetInstance.value?.budgetId,
        { ownerType: BUDGET_OWNER_TYPE_CATEGORY, ownerId: props.category.id }
      );
    };

    const handleToggleFavourite = () => {
      categoryStore.update(
        categoryFromStore.value.id,
        { favourite: !categoryFromStore.value.favourite },
        { fetchSingle: true }
      );
    }

    return {
      t,
      isDisabled,
      categoriesPath,
      categoryFromStore,
      loadingCategory,
      budgetInstance,
      tabsConfig,
      ICON_BUDGETS,
      handleEdit,
      handleDisable,
      handleReenable,
      handleSetBudget,
      handleDateRangeChange,
      handleNewSubcategory,
      handleToggleFavourite,
    };
  },
};
</script>
