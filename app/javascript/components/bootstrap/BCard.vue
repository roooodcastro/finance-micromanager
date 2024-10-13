<template>
  <div
    class="card"
    :class="{ 'h-100': fullHeight }"
  >
    <div class="card-body">
      <div
        v-if="title || $slots.header"
        class="BCard__title d-flex justify-content-between align-items-center"
      >
        <h4
          v-if="title"
          class="card-title m-0"
        >
          {{ title }}
          <span
            v-if="subTitle"
            class="fs-6 d-block mt-2"
          >
            {{ subTitle }}
          </span>
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
    subTitle: {
      type: String,
      default: null,
    },
    noBody: {
      type: Boolean,
      default: false,
    },
    fullHeight: {
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
  margin: -1rem;
}

.BCard__title {
  margin-bottom: 2rem;
}
</style>
