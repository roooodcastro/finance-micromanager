<template>
  <NoRecordsFound v-if="!categories.length" />
  <div
    v-else
    class="CategoriesList list-group"
  >
    <template
      v-for="category in categories"
      :key="category.id"
    >
      <CategoryListItem :category="category" />
    </template>
  </div>
</template>

<script>
import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import CategoryListItem from '~/components/categories/CategoryListItem.vue';
import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';

export default {
  components: {
    CategoryListItem,
    NoRecordsFound,
  },

  setup() {
    const categoryStore = useCategoryStore();

    // Load categories from props
    const { categories } = storeToRefs(categoryStore);

    // Reload categories if profile has changed while this list is shown
    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => categoryStore.fetchCollection());

    return {
      t: I18n.scopedTranslator('views.categories.index'),
      categories,
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
</style>
