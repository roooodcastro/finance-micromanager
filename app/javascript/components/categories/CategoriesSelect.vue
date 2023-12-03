<template>
  <select
    v-bind="$attrs"
    class="form-select"
    :value="modelValue ?? $attrs.value"
    @change="$emit('update:modelValue', $event.target.value)"
  >
    <option />
    <option
      v-for="category in categories"
      :key="category.id"
      :value="category.id"
    >
      {{ category.name }}
    </option>
  </select>
</template>

<script>
export default {
  props: {
    categories: {
      type: Array,
      required: true
    },
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue'],
};
</script>
