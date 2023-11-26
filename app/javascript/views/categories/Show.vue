<template>
  <PageHeader
    :title="t('title')"
    :sub-title="categoryFromStore.name"
    class="flex-wrap"
  >
    <template v-slot:actions>
      <div class="mt-2 mt-lg-0">
        <a
          :href="editCategoryPath({ id: categoryFromStore.id })"
          class="btn btn-sm btn-outline-secondary"
        >
          <FontAwesomeIcon icon="pen-to-square" />
          <span class="ms-2">
            {{ t('edit') }}
          </span>
        </a>
        <a
          :href="editCategoryPath({ id: categoryFromStore.id })"
          class="btn btn-sm btn-danger ms-2"
        >
          <FontAwesomeIcon :icon="['far', 'square-minus']" />
          <span class="ms-2">
            {{ t('disable') }}
          </span>
        </a>
      </div>
    </template>
  </PageHeader>

  <DateRangeSelector
    class="mb-3"
    @change="handleDateRangeChange"
  />

  <div class="row">
    <div class="col-12 col-xl-6">
      <CategorySummary :category="categoryFromStore" />
    </div>

    <div class="col-12 col-xl-6">
      <div class="card mt-3 mt-xl-0">
        <div class="card-header">
          <h5 class="m-0">
            {{ t('sub_header_recent_transactions') }}
          </h5>
        </div>
        <RecentTransactionsList
          :transactions="categoryFromStore.recentTransactions"
        />
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

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import PageHeader from '~/components/layout/PageHeader.vue';
import RecentTransactionsList from '~/components/transactions/RecentTransactionsList.vue';
import CategorySummary from '~/components/categories/CategorySummary.vue';
import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';

export default {
  components: {
    CategorySummary,
    DateRangeSelector,
    FontAwesomeIcon,
    PageHeader,
    RecentTransactionsList,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const editCategoryPath = categoriesApi.edit.path;

    const dateRangeStore = useDateRangeStore();
    const categoryStore = useCategoryStore();

    const { startDate, endDate } = storeToRefs(dateRangeStore);
    const { category: categoryFromStore } = storeToRefs(categoryStore);

    categoryFromStore.value = props.category;

    const handleDateRangeChange = () => {
      categoryStore.fetchCategory(props.category.id, startDate.value, endDate.value);
    };

    return {
      t: I18n.scopedTranslator('views.categories.show'),
      editCategoryPath,
      categoryFromStore,
      handleDateRangeChange,
    };
  },
};
</script>
