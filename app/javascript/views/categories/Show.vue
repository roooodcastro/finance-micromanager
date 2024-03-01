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
            v-if="!isDisabled"
            toggle-icon="gear"
            :toggle-label="t('subcategories_options')"
          >
            <DropdownMenuItem
              :label="t('new_subcategory')"
              icon="plus"
              @click="handleNewSubcategory"
            />

            <hr class="my-2">

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
import { computed, watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { categories as categoriesApi } from '~/api/all.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import { ICON_CATEGORIES } from '~/utils/Constants.js';

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
import WarningAlert from '~/components/bootstrap/WarningAlert.vue';

export default {
  components: {
    WarningAlert,
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
    const floatingActionButtonStore = useFloatingActionButtonStore();

    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.categories.floating_button_label'),
      icon: ICON_CATEGORIES,
      callback: () => categoryStore.openFormModal(null),
    });

    const { transactions } = storeToRefs(transactionStore);

    // Load categories from props
    const { category: categoryFromStore, loading: loadingCategory } = storeToRefs(categoryStore);
    categoryFromStore.value = props.category;

    const isDisabled = computed(() => !!categoryFromStore.value.disabledAt);

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

    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => window.location.href = categoriesApi.index.path());

    watch(subcategoriesFromStore, () => { categoryStore.fetchSingle(props.category.id) });
    watch(transactions, () => { categoryStore.fetchSingle(props.category.id) });

    const handleEdit = () => categoryStore.openFormModal(props.category.id);
    const handleDisable = () => categoryStore.disable(props.category.id, { fetchSingle: true });
    const handleReenable = () => categoryStore.reenable(props.category.id, { fetchSingle: true });
    const handleNewSubcategory = () => subcategoryStore.openFormModal(null);
    const handleShowDisabledSubcategories = () => subcategoryStore.setShowDisabled(!showDisabledSubcategories.value);
    const handleDateRangeChange = () => {
      categoryStore.fetchSingle(props.category.id);
      transactionStore.fetchCollection();
    }

    return {
      t: I18n.scopedTranslator('views.categories.show'),
      isDisabled,
      categoriesPath,
      categoryFromStore,
      subcategoriesFromStore,
      showDisabledSubcategories,
      loadingCategory,
      handleEdit,
      handleDisable,
      handleReenable,
      handleDateRangeChange,
      handleNewSubcategory,
      handleShowDisabledSubcategories,
    };
  },
};
</script>
