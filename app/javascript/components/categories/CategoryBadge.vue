<template>
  <div
    class="badge fs-5 py-1"
    :style="{ backgroundColor: category.color, color: textColor }"
  >
    {{ subcategory?.displayName ?? category.name }}
  </div>
</template>

<script>
import { constrastingColor } from '~/utils/ColorThemeUtils.js';

export default {
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

    return {
      textColor,
    };
  },
}
</script>
