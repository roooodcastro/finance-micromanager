<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <a
          :href="newCategoryPath"
          class="btn btn-outline-secondary"
        >
          {{ t('new') }}
        </a>
      </template>
    </PageHeader>

    <CategoriesList :categories="categories" />
  </div>
</template>

<script>
import { categories } from '~/api';
import I18n from '~/utils/I18n';

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
      t: I18n.scopedTranslator('views.categories.index'),
    };
  },
};
</script>
