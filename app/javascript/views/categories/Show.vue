<template>
  <PageHeader
    :title="categoryFromStore.name"
    :sub-title="t('title')"
    :back-button-href="categoriesPath"
    class="flex-wrap"
  >
    <template v-slot:actions>
      <DropdownMenuItem
        :label="t('new_subcategory')"
        icon="plus"
        @click="handleNewSubcategory"
      />
      <DropdownMenuItem
        :href="editCategoryPath({ id: categoryFromStore.id })"
        :label="t('edit')"
        icon="pen-to-square"
      />
      <DropdownMenuItem
        :href="editCategoryPath({ id: categoryFromStore.id })"
        :label="t('disable')"
        :icon="['far', 'square-minus']"
        class="text-danger"
      />
    </template>
  </PageHeader>

  <SubcategoryForm :category="categoryFromStore" />

  <DateRangeSelector
    class="mb-3"
    @change="handleDateRangeChange"
  />

  <div class="row">
    <div class="col-12 col-xl-6">
      <CategorySummary :category="categoryFromStore" />

      <div
        v-if="subcategoriesFromStore.length"
        class="card mt-3"
      >
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="m-0">
            {{ t('sub_header_subcategories') }}
          </h5>

          <DropdownMenu
            toggle-icon="gear"
            :toggle-label="t('subcategories_options')"
          >
            <DropdownMenuCheckItem
              :label="t('show_all_subcategories')"
              :checked="showDisabledSubcategories"
              @click="handleShowDisabledSubcategories"
            />
          </DropdownMenu>
        </div>
        <SubcategoriesList :subcategories="categoryFromStore.subcategories" />
      </div>
    </div>

    <div class="col-12 col-xl-6">
      <div class="card mt-3 mt-xl-0">
        <div class="card-header">
          <h5 class="m-0">
            {{ t('sub_header_recent_transactions') }}
          </h5>
        </div>
        <RecentTransactionsList :transactions="categoryFromStore.recentTransactions" />
      </div>
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';
import I18n from '~/utils/I18n.js';
import { categories as categoriesApi } from '~/api/all.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import RecentTransactionsList from '~/components/transactions/RecentTransactionsList.vue';
import CategorySummary from '~/components/categories/CategorySummary.vue';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';
import DropdownMenu from '~/components/ui/DropdownMenu.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import DropdownMenuCheckItem from '~/components/ui/DropdownMenuCheckItem.vue';
import SubcategoriesList from '~/components/subcategories/SubcategoriesList.vue';
import SubcategoryForm from '~/components/subcategories/SubcategoryForm.vue';

export default {
  components: {
    SubcategoryForm,
    CategorySummary,
    DateRangeSelector,
    DropdownMenu,
    DropdownMenuCheckItem,
    DropdownMenuItem,
    PageHeader,
    RecentTransactionsList,
    SubcategoriesList,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const categoriesPath = categoriesApi.index.path();
    const editCategoryPath = categoriesApi.edit.path;

    const dateRangeStore = useDateRangeStore();
    const categoryStore = useCategoryStore();
    const subcategoryStore = useSubcategoryStore();
    const transactionStore = useTransactionStore();

    const { startDate, endDate } = storeToRefs(dateRangeStore);

    // Load categories from props
    const { category: categoryFromStore } = storeToRefs(categoryStore);
    categoryFromStore.value = props.category;

    const { transactions } = storeToRefs(transactionStore);
    transactions.value = categoryFromStore.value.recentTransactions;

    // Load subcategories from props
    const {
      categoryId: subcategoryCategoryId,
      subcategories: subcategoriesFromStore,
      showDisabled: showDisabledSubcategories,
    } = storeToRefs(subcategoryStore);
    subcategoriesFromStore.value = props.category.subcategories;
    subcategoryCategoryId.value = props.category.id;

    const handleDateRangeChange = () => categoryStore.fetchCategory(props.category.id, startDate.value, endDate.value);
    const handleNewSubcategory = () => subcategoryStore.openFormModal(null);
    const handleShowDisabledSubcategories = () => subcategoryStore.setShowDisabled(!showDisabledSubcategories.value);

    return {
      t: I18n.scopedTranslator('views.categories.show'),
      categoriesPath,
      editCategoryPath,
      categoryFromStore,
      subcategoriesFromStore,
      showDisabledSubcategories,
      handleDateRangeChange,
      handleNewSubcategory,
      handleShowDisabledSubcategories,
    };
  },
};
</script>
