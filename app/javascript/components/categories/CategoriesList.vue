<template>
  <div>
    <div class="CategoriesList list-group">
      <template
        v-for="category in categories"
        :key="category.id"
      >
        <CategoryListItem :category="category" />
      </template>
    </div>
  </div>
</template>

<script>
import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import { categories as categoriesApi } from '~/api/all.js';
import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import CategoryListItem from '~/components/categories/CategoryListItem.vue';

export default {
  components: {
    CategoryListItem,
  },

  setup() {
    const categoryStore = useCategoryStore();

    // Load categories from props
    const { categories } = storeToRefs(categoryStore);

    // Reload categories if profile has changed while this list is shown
    const profileStore = useProfileStore();
    watch(
      () => profileStore.currentProfile,
      () => {
        categoriesApi.index().then(response => categories.value = response.categories);
      },
    );

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

@include media-breakpoint-down(md) {
  .CategoriesList {
    margin-left: -1rem;
    margin-right: -1rem;
    width: calc(100% + 2rem);
  }
}
</style>
