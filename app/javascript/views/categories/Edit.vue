<template>
  <div>
    <PageHeader :page-title="`Edit Category '${category.name}'`" />

    <div class="row justify-content-center">
      <div class="col col-md-8 col-lg-6 col-xl-4">
        <CategoryForm :category="category" />
      </div>
    </div>
  </div>
</template>

<script>
import { categories } from '~/api';

import PageHeader from '~/components/layout/PageHeader.vue';
import CategoryForm from '~/components/categories/CategoryForm.vue';

export default {
  components: {
    CategoryForm,
    PageHeader,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const listCategoriesPath = categories.list.path();

    return {
      listCategoriesPath,
    };
  },
};
</script>
