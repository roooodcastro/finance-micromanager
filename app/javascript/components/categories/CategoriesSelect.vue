<template>
  <select
    v-bind="$attrs"
    class="form-select"
    :value="modelValue ?? $attrs.value"
    @change="$emit('update:modelValue', $event.target.value)"
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

  emits: ['update:modelValue'],

  setup() {
    const categoryStore = useCategoryStore();
    const { categoriesForSelect: options } = storeToRefs(categoryStore);

    return { options };
  },
};
</script>
