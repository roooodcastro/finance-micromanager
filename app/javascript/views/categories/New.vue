<template>
  <div>
    <PageHeader :page-title="t('new_title')" />

    <div class="row justify-content-center">
      <div class="col col-md-8 col-lg-6 col-xl-4">
        <CategoryForm :category="category" />
      </div>
    </div>
  </div>
</template>

<script>
import { categories } from '~/api';
import I18n from '~/utils/I18n';

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
    const createCategoryPath = categories.create.path();

    return {
      listCategoriesPath,
      createCategoryPath,
      t: I18n.scopedTranslator('views.categories.new_edit'),
    };
  },
};
</script>
