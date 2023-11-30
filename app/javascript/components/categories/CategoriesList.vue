<template>
  <div>
    <Pagination
      :pagination="pagination"
      class="mb-3"
      compact
      @change="handlePageChange"
    />

    <div class="CategoriesList">
      <template
        v-for="category in categoriesFromStore"
        :key="category.id"
      >
        <CategoryListItem
          :category="category"
        />
      </template>
    </div>

    <Pagination
      :pagination="pagination"
      class="mt-3"
      @change="handlePageChange"
    />
  </div>
</template>

<script>
import { watch, toRef } from 'vue';
import { storeToRefs } from 'pinia';

import { categories as categoriesApi } from '~/api';
import I18n from '~/utils/I18n';
import useWalletStore from '~/stores/WalletStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import Pagination from "~/components/rails/Pagination.vue";
import CategoryListItem from '~/components/categories/CategoryListItem.vue';

export default {
  components: {
    CategoryListItem,
    Pagination,
  },

  props: {
    categories: {
      type: Array,
      required: true,
    },
    pagination: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const categoryStore = useCategoryStore();

    // Load categories from props
    const {
      categories: categoriesFromStore,
    } = storeToRefs(categoryStore);

    categoriesFromStore.value = toRef(props.categories);

    // Reload categories if wallet has changed while this page is open
    const walletStore = useWalletStore();
    watch(
      () => walletStore.currentWallet,
      () => {
        categoriesApi.index().then(response => categoriesFromStore.value = response.categories);
      },
    );

    const handlePageChange = () => categoryStore.fetchCategories();

    return {
      handlePageChange,
      t: I18n.scopedTranslator('views.categories.index'),
      categoriesFromStore,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.CategoriesList__color-indicator {
  border: 1px solid $table-border-color;
  display: inline-block;
  width: 2em;
  height: 2em;
}

@include media-breakpoint-down(md) {
  .CategoriesList {
    margin-left: -1rem;
    margin-right: -1rem;
    width: calc(100% + 2rem);
  }
}
</style>
