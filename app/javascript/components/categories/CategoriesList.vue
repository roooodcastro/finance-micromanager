<template>
  <div>
    <div class="CategoriesList">
      <template
        v-for="category in categoriesFromStore"
        :key="category.id"
      >
        <CategoryListItem
          :category="category"
        />
      </template>
    </div>
  </div>
</template>

<script>
import { watch, toRef } from 'vue';
import { storeToRefs } from 'pinia';

import { categories as categoriesApi } from '~/api/all.js';
import I18n from '~/utils/I18n.Js';
import useProfileStore from '~/stores/ProfileStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import CategoryListItem from '~/components/categories/CategoryListItem.vue';

export default {
  components: {
    CategoryListItem,
  },

  props: {
    categories: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const categoryStore = useCategoryStore();

    // Load categories from props
    const {
      categories: categoriesFromStore,
    } = storeToRefs(categoryStore);

    categoriesFromStore.value = toRef(props.categories);

    // Reload categories if profile has changed while this list is shown
    const profileStore = useProfileStore();
    watch(
      () => profileStore.currentProfile,
      () => {
        categoriesApi.index().then(response => categoriesFromStore.value = response.categories);
      },
    );

    return {
      t: I18n.scopedTranslator('views.categories.index'),
      categoriesFromStore,
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
