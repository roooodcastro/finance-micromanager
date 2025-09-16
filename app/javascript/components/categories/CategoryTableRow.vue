<template>
  <div class="GridRow__left">
    <div class="d-flex gap-2 align-items-center">
      <StarsSlider
        v-if="!isSystem && !isDisabled && category.favourite"
        :max="1"
        :value="1"
        class="text-warning"
      />

      <span :class="{ 'text-muted': isDisabled }">
        {{ category.name }}
      </span>

      <Badge
        v-if="isDisabled"
        type="disabled"
        i18n-scope="views.categories.show.disabled"
      />

      <Badge
        v-if="isSystem"
        type="system"
      />

      <Badge
        v-if="isIncome"
        type="income"
      />
    </div>

    <div>
      {{ subcategoriesNames }}
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';

import Badge from '~/components/ui/Badge.vue';
import StarsSlider from '~/components/ui/StarsSlider.vue';

export default {
  components: {
    Badge,
    StarsSlider,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.components.categories_list');

    const isDisabled = computed(() => !!props.category.disabledAt);
    const isSystem = computed(() => props.category.system);
    const isIncome = computed(() => props.category.categoryType === 'income');

    const subcategoriesNames = computed(() => {
      return props.category.subcategories.map(subcategory => subcategory.name).join(', ') || '';
    });

    return {
      t,
      isDisabled,
      isSystem,
      isIncome,
      subcategoriesNames,
    };
  }
};
</script>
