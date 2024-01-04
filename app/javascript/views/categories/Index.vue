<template>
  <div>
    <CategoryForm />

    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :label="t('new')"
          icon="plus"
          @click="handleNew"
        />
      </template>
    </PageHeader>

    <CategoriesList />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import CategoriesList from '~/components/categories/CategoriesList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import CategoryForm from '~/components/categories/CategoryForm.vue';

export default {
  components: {
    CategoriesList,
    CategoryForm,
    PageHeader,
    DropdownMenuItem,
  },

  props: {
    categories: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const categoryStore = useCategoryStore();
    const { categories: categoriesFromStore } = storeToRefs(categoryStore);
    categoriesFromStore.value = props.categories;

    const handleNew = () => categoryStore.openFormModal(null);

    return {
      t: I18n.scopedTranslator('views.categories.index'),
      categoriesFromStore,
      handleNew,
    };
  },
};
</script>
