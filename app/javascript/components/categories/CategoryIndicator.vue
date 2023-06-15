<template>
  <span
    class="CategoryIndicator__badge"
    :style="{ borderColor: category.color }"
  >
    <span
      class="CategoryIndicator__color-indicator"
      :style="{ backgroundColor: category.color }"
    />

    {{ category.name }}
  </span>
</template>

<script>
export default {
  props: {
    category: {
      type: Object,
      required: true,
    },
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.CategoryIndicator__badge {
  border: 1px solid;
  border-radius: 4px;
  padding: 0.25em 0.5em;
  font-weight: bold;
}

.CategoryIndicator__color-indicator {
  display: inline-block;
  width: 0.75em;
  height: 0.75em;
  border-radius: 50%;
}
</style>
