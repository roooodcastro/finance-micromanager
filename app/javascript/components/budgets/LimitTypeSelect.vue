<template>
  <nav
    v-bind="$attrs"
    class="nav nav-pills nav-justified mb-3"
  >
    <a
      v-for="limitType in availableLimitTypes"
      :key="limitType"
      href="#"
      class="nav-link text-center"
      :class="{ 'active': limitType === (modelValue ?? $attrs.value) }"
      @click="handleChange(limitType)"
    >
      {{ t(`limit_type_${limitType}_label`) }}
    </a>
  </nav>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import { BUDGET_VALID_LIMIT_TYPES } from '~/utils/Constants.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
    limitOwnerType: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(props, { emit }) {
    const t = I18n.scopedTranslator('views.budgets.form');

    const availableLimitTypes = computed(() => BUDGET_VALID_LIMIT_TYPES[props.limitOwnerType] ?? []);
    const handleChange = (limitType) => {
      emit('update:modelValue', limitType);
      emit('change', limitType);
    };

    return {
      t,
      availableLimitTypes,
      handleChange,
    };
  },
};
</script>
