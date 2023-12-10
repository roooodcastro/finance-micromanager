<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :href="newCategoryPath"
          :label="t('new')"
          icon="plus"
        />
      </template>
    </PageHeader>

    <div class="list-group">
      <CategoriesList
        :categories="categories"
      />
    </div>
  </div>
</template>

<script>
import { categories } from '~/api/all.js';
import I18n from '~/utils/I18n.Js';

import PageHeader from '~/components/layout/PageHeader.vue';
import CategoriesList from '~/components/categories/CategoriesList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';

export default {
  components: {
    CategoriesList,
    PageHeader,
    DropdownMenuItem,
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
