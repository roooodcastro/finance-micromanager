<template>
  <ListItem
    :record="category"
    :actions-component="CategoryActions"
    :item-container-class="category.system ? 'bg-light' : 'bg-white'"
  >
    <a
      class="text-decoration-none list-group-item-action d-flex align-items-center p-2 min-width-0"
      :href="showCategoryPath(category.id)"
    >
      <span
        class="CategoriesList__color-indicator rounded-circle me-3 flex-shrink-0"
        :style="{ backgroundColor: category.color }"
      />
      <div class="d-flex flex-column min-width-0">
        <span class="d-flex align-items-center gap-2">
          <span
            v-if="isDisabled"
            class="badge text-bg-danger"
          >
            {{ t('disabled') }}
          </span>

          {{ category.name }}
        </span>
        <span class="fs-6 text-muted text-truncate">
          {{ subcategoriesNames }}
        </span>
      </div>
    </a>
  </ListItem>
</template>

<script>
import { computed, markRaw } from 'vue';

import I18n from '~/utils/I18n.js';
import { categories as categoriesApi } from '~/api/all.js';

import CategoryActions from '~/components/categories/CategoryActions.vue';
import ListItem from '~/components/ui/ListItem.vue';

export default {
  components: { ListItem },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    markRaw(CategoryActions);
    const t = I18n.scopedTranslator('views.categories.index');

    const showCategoryPath = (categoryId) => categoriesApi.show.path({ id: categoryId });

    const isDisabled = computed(() => !!props.category.disabledAt);

    const subcategoriesNames = computed(() => {
      return props.category.subcategories.map(subcategory => subcategory.name).join(', ');
    });

    return {
      t,
      showCategoryPath,
      isDisabled,
      subcategoriesNames,
      CategoryActions,
    };
  }
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
