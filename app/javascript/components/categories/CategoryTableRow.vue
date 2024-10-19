<template>
  <div class="GridRow__left">
    <div class="d-flex gap-2 align-items-center">
      <span :class="{ 'text-muted': isDisabled }">
        {{ category.name }}
      </span>

      <DisabledBadge v-if="isDisabled" />

      <span
        v-if="isSystem"
        class="badge text-bg-dark"
      >
        {{ t('system') }}
      </span>
    </div>

    <div>
      {{ subcategoriesNames }}
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';

import DisabledBadge from '~/components/bootstrap/DisabledBadge.vue';

export default {
  components: {
    DisabledBadge,
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

    const subcategoriesNames = computed(() => {
      return props.category.subcategories.map(subcategory => subcategory.name).join(', ') || '-';
    });

    return {
      t,
      isDisabled,
      isSystem,
      subcategoriesNames,
    };
  }
};
</script>
