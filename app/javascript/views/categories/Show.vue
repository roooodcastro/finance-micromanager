<template>
  <PageHeader
    :title="t('title')"
    :sub-title="category.name"
    class="flex-wrap"
  >
    <template v-slot:actions>
      <div class="mt-2 mt-lg-0">
        <a
          :href="editCategoryPath({ id: category.id })"
          class="btn btn-sm btn-outline-secondary"
        >
          <FontAwesomeIcon icon="pen-to-square" />
          <span class="ms-2">
            {{ t('edit') }}
          </span>
        </a>
        <a
          :href="editCategoryPath({ id: category.id })"
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

  <div class="row">
    <div class="col-12 col-xl-6">
      <CategorySummary :category="category" />
    </div>

    <div class="col-12 col-xl-6">
      <div class="card mt-3 mt-xl-0">
        <div class="card-header">
          <h5 class="m-0">
            {{ t('sub_header_recent_transactions') }}
          </h5>
        </div>
        <RecentTransactionsList
          :transactions="category.recentTransactions"
        />
      </div>
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n';
import { categories as categoriesApi } from '~/api';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import PageHeader from '~/components/layout/PageHeader.vue';
import RecentTransactionsList from '~/components/transactions/RecentTransactionsList.vue';
import CategorySummary from '~/components/categories/CategorySummary.vue';

export default {
  components: {
    CategorySummary,
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

  setup() {
    const editCategoryPath = categoriesApi.edit.path;

    return {
      t: I18n.scopedTranslator('views.categories.show'),
      editCategoryPath,
    };
  },
};
</script>
