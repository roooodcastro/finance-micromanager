<template>
  <select
    v-bind="$attrs"
    class="form-select"
    :value="modelValue ?? $attrs.value"
    @change="handleChange"
  >
    <option value="">
      {{ placeholder }}
    </option>
    <option
      v-for="option in options(false)"
      :key="option.value"
      :value="option.value"
    >
      {{ option.label }}
    </option>
  </select>
</template>

<script>
import { storeToRefs } from 'pinia';

import useCategoryStore from '~/stores/CategoryStore.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
    placeholder: {
      type: String,
      default: '',
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(_, { emit }) {
    const categoryStore = useCategoryStore();
    const { categoriesForSelect: options } = storeToRefs(categoryStore);

    const handleChange = (ev) => {
      emit('update:modelValue', ev.target.value);
      emit('change', ev.target.value);
    };

    return {
      options,
      handleChange,
    };
  },
};
</script>
