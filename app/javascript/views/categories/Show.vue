<template>
  <PageHeader
    :title="categoryFromStore.name"
    :sub-title="t('title')"
    :back-button-href="categoriesPath"
  >
    <template
      v-if="!categoryFromStore.system"
      v-slot:actions
    >
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
        :label="t('disable')"
        icon="ban"
        class="text-danger"
        @click="handleDisable"
      />
    </template>
  </PageHeader>

  <DateRangeSelector
    class="mb-3"
    @change="handleDateRangeChange"
  />

  <div class="row">
    <div class="col-12 col-xl-6">
      <CategorySummary
        :category="categoryFromStore"
        :loading="loadingCategory"
      />

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
        <TransactionsList
          compact
          card-body
        />
      </div>
    </div>
  </div>

  <SubcategoryForm :category="categoryFromStore" />
  <CategoryForm />
</template>

<script>
import { storeToRefs } from 'pinia';
import I18n from '~/utils/I18n.js';
import { categories as categoriesApi } from '~/api/all.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import CategorySummary from '~/components/categories/CategorySummary.vue';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';
import DropdownMenu from '~/components/ui/DropdownMenu.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import DropdownMenuCheckItem from '~/components/ui/DropdownMenuCheckItem.vue';
import SubcategoriesList from '~/components/subcategories/SubcategoriesList.vue';
import SubcategoryForm from '~/components/subcategories/SubcategoryForm.vue';
import CategoryForm from '~/components/categories/CategoryForm.vue';

export default {
  components: {
    CategoryForm,
    CategorySummary,
    DateRangeSelector,
    DropdownMenu,
    DropdownMenuCheckItem,
    DropdownMenuItem,
    PageHeader,
    SubcategoriesList,
    SubcategoryForm,
    TransactionsList,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const categoriesPath = categoriesApi.index.path();

    const categoryStore = useCategoryStore();
    const subcategoryStore = useSubcategoryStore();
    const transactionStore = useTransactionStore();

    // Load categories from props
    const { category: categoryFromStore, loading: loadingCategory } = storeToRefs(categoryStore);
    categoryFromStore.value = props.category;

    transactionStore.setFetchParams({ categoryIds: props.category.id, daysToShow: 0 });
    transactionStore.fetchCollection();

    // Load subcategories from props
    const {
      categoryId: subcategoryCategoryId,
      subcategories: subcategoriesFromStore,
      showDisabled: showDisabledSubcategories,
    } = storeToRefs(subcategoryStore);
    subcategoriesFromStore.value = props.category.subcategories;
    subcategoryCategoryId.value = props.category.id;

    const handleEdit = () => categoryStore.openFormModal(props.category.id);
    const handleDisable = () => categoryStore.disable(props.category.id);
    const handleNewSubcategory = () => subcategoryStore.openFormModal(null);
    const handleShowDisabledSubcategories = () => subcategoryStore.setShowDisabled(!showDisabledSubcategories.value);
    const handleDateRangeChange = () => {
      categoryStore.fetchSingle(props.category.id);
      transactionStore.fetchCollection();
    }

    return {
      t: I18n.scopedTranslator('views.categories.show'),
      categoriesPath,
      categoryFromStore,
      subcategoriesFromStore,
      showDisabledSubcategories,
      loadingCategory,
      handleEdit,
      handleDisable,
      handleDateRangeChange,
      handleNewSubcategory,
      handleShowDisabledSubcategories,
    };
  },
};
</script>
