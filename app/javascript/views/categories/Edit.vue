<template>
  <div>
    <PageHeader :page-title="t('edit_title', { category: category.name })" />

    <div class="row justify-content-center">
      <div class="col col-md-8 col-lg-6 col-xl-4">
        <CategoryForm :category="category" />
      </div>
    </div>
  </div>
</template>

<script>
import { categories } from '~/api/all.js';
import I18n from '~/utils/I18n.js';

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
    const listCategoriesPath = categories.index.path();

    return {
      listCategoriesPath,
      t: I18n.scopedTranslator('views.categories.form'),
    };
  },
};
</script>
