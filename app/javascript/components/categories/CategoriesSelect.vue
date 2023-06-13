<template>
  <select
    v-bind="$attrs"
    class="form-select"
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
  },
};
</script>
