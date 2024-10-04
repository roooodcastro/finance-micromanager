<template>
  <div class="card overflow-hidden h-100">
    <div class="card-body">
      <div
        v-if="title || $slots.header"
        class="d-flex justify-content-between align-items-center"
      >
        <h4
          v-if="title"
          class="card-title"
        >
          {{ title }}
        </h4>
        <slot name="header" />
      </div>

      <div :class="{ 'BCard__no-body': noBody }">
        <slot />
      </div>
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

.BCard__no-body {
  margin: 0 -1rem -1rem -1rem;
}
</style>
