<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <a
          :href="newCategoryPath"
          class="btn btn-sm btn-outline-secondary mt-2 mt-lg-0"
        >
          <FontAwesomeIcon
              icon="plus"
              size="lg"
              class="me-2"
          />
          {{ t('new') }}
        </a>
      </template>
    </PageHeader>

    <div class="list-group">
      <CategoriesList
        :categories="categories"
        :pagination="pagination"
      />
    </div>
  </div>
</template>

<script>
import { categories } from '~/api';
import I18n from '~/utils/I18n';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import PageHeader from '~/components/layout/PageHeader.vue';
import CategoriesList from '~/components/categories/CategoriesList.vue';

export default {
  components: {
    CategoriesList,
    FontAwesomeIcon,
    PageHeader,
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

  setup() {
    const newCategoryPath = categories.new.path();

    return {
      newCategoryPath,
      t: I18n.scopedTranslator('views.categories.index'),
    };
  },
};
</script>
