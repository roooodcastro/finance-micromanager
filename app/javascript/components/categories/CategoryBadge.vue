<template>
  <a
    :href="categoryPath"
    class="CategoryBadge badge fs-5 py-1 text-decoration-none"
    :style="{
      '--category-color': category.color,
      '--category-text-color': textColor,
    }"
  >
    <FontAwesomeIcon
      :icon="ICON_CATEGORIES"
      class="me-2"
    />

    {{ subcategory?.displayName ?? category.name }}
  </a>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { ICON_CATEGORIES } from '~/utils/Constants.js';
import { constrastingColor } from '~/utils/ColorThemeUtils.js';
import { categories as categoriesApi } from '~/api/all.js';

export default {
  components: { FontAwesomeIcon },

  props: {
    category: {
      type: Object,
      required: true,
    },
    subcategory: {
      type: Object,
      default: () => {},
    },
  },

  setup(props) {
    const textColor = constrastingColor(props.category.color);

    const categoryPath = categoriesApi.show.path({ id: props.category.id });

    return {
      textColor,
      categoryPath,
      ICON_CATEGORIES,
    };
  },
}
</script>

<style lang="scss" scoped>
  .CategoryBadge {
    background-color: var(--category-color);
    color: var(--category-text-color);
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
}
</style>
