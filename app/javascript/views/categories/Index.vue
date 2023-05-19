<template>
  <div>
    <PageHeader title="Categories">
      <template v-slot:actions>
        <a
          :href="newCategoryPath"
          class="btn btn-outline-secondary"
        >
          New Category
        </a>
      </template>
    </PageHeader>

    <CategoriesList :categories="categories" />
  </div>
</template>

<script>
import { categories } from '~/api';

import PageHeader from '~/components/layout/PageHeader.vue';
import CategoriesList from '~/components/categories/CategoriesList.vue';

export default {
  components: {
    CategoriesList,
    PageHeader,
  },

  props: {
    categories: {
      type: Array,
      required: true,
    },
  },

  setup() {
    const newCategoryPath = categories.new.path();

    return {
      newCategoryPath,
    };
  },
};
</script>
