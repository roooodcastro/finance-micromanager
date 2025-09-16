<template>
  <select
    v-bind="$attrs"
    class="form-select"
    :value="modelValue ?? $attrs.value"
    @change="handleChange"
  >
    <option
      v-for="categoryType in USER_SELECTABLE_CATEGORY_TYPES"
      :key="categoryType"
      :value="categoryType"
    >
      {{ t(categoryType) }}
    </option>
  </select>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { USER_SELECTABLE_CATEGORY_TYPES } from '~/utils/Constants.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(_, { emit }) {
    const t = I18n.scopedTranslator('views.components.categories.category_type_select');

    const handleChange = (ev) => {
      emit('update:modelValue', ev.target.value);
      emit('change', ev.target.value);
    };

    return {
      t,
      USER_SELECTABLE_CATEGORY_TYPES,
      handleChange,
    };
  },
};
</script>
