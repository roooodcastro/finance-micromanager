<template>
  <PageHeader
    :title="t('title')"
    :sub-title="categoryFromStore.name"
    :back-button-href="categoriesPath"
    class="flex-wrap"
  >
    <template v-slot:actions>
      <PageHeaderActionLink
        href="#"
        data-bs-toggle="modal"
        data-bs-target="#subcategoryFormModal"
        :label="t('new_subcategory')"
        icon="plus"
        @click="handleNewSubcategory"
      />
      <PageHeaderActionLink
        :href="editCategoryPath({ id: categoryFromStore.id })"
        :label="t('edit')"
        icon="pen-to-square"
      />
      <PageHeaderActionLink
        :href="editCategoryPath({ id: categoryFromStore.id })"
        :label="t('disable')"
        :icon="['far', 'square-minus']"
        class="text-danger"
      />
    </template>
  </PageHeader>

  <SubcategoryFormModal />

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
        <div class="card-header">
          <h5 class="m-0">
            {{ t('sub_header_subcategories') }}
          </h5>
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
import I18n from '~/utils/I18n';
import { categories as categoriesApi } from '~/api';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import RecentTransactionsList from '~/components/transactions/RecentTransactionsList.vue';
import CategorySummary from '~/components/categories/CategorySummary.vue';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';
import PageHeaderActionLink from '~/components/layout/PageHeaderActionLink.vue';
import SubcategoryFormModal from '~/components/subcategories/SubcategoryFormModal.vue';
import SubcategoriesList from '~/components/subcategories/SubcategoriesList.vue';

export default {
  components: {
    SubcategoriesList,
    SubcategoryFormModal,
    CategorySummary,
    DateRangeSelector,
    PageHeader,
    PageHeaderActionLink,
    RecentTransactionsList,
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

    const { startDate, endDate } = storeToRefs(dateRangeStore);

    // Load categories from props
    const { category: categoryFromStore } = storeToRefs(categoryStore);
    categoryFromStore.value = props.category;

    // Load subcategories from props
    const { subcategories: subcategoriesFromStore } = storeToRefs(subcategoryStore);
    subcategoriesFromStore.value = props.category.subcategories;

    const handleDateRangeChange = () => categoryStore.fetchCategory(props.category.id, startDate.value, endDate.value);
    const handleNewSubcategory = () => subcategoryStore.setSubcategoryIdForFormModal(null);

    return {
      t: I18n.scopedTranslator('views.categories.show'),
      categoriesPath,
      editCategoryPath,
      categoryFromStore,
      subcategoriesFromStore,
      handleDateRangeChange,
      handleNewSubcategory,
    };
  },
};
</script>
