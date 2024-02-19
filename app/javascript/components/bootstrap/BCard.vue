<template>
  <div class="card overflow-hidden">
    <div
      v-if="title || $slots.header"
      class="card-header"
    >
      <h5
        v-if="title"
        class="m-0"
      >
        {{ title }}
      </h5>
      <slot name="header" />
    </div>
    <slot v-if="noBody" />
    <div
      v-else
      class="card-body"
    >
      <slot />
    </div>
  </div>
</template>

<script>
export default {
  props: {
    title: {
      type: String,
      default: null,
    },
    noBody: {
      type: Boolean,
      default: false,
    },
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .card {
    border-radius: 0 !important;
  }
}
</style>
