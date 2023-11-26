<template>
  <header
    v-if="title || $slots.default"
    class="d-flex align-items-center justify-content-between mt-2 mt-lg-4 flex-wrap"
  >
    <h1
      v-if="title || $slots.default"
      class="PageHeader__h1 d-flex flex-column mb-0 mb-lg-2"
    >
      <template v-if="title">
        <span>
          {{ title }}
        </span>
      </template>
      <slot v-else />

      <template v-if="subTitle">
        <span class="fs-4 text-muted d-block">
          {{ subTitle }}
        </span>
      </template>
    </h1>

    <slot name="actions" />
  </header>

  <hr />
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
      default: '',
    },
    pageTitle: {
      type: String,
      default: '',
    },
  },
  setup(props) {
    if (props.pageTitle || props.title) {
      document.title = `${props.pageTitle || props.title} - Finance MicroManager`;
    }
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .PageHeader__h1 {
    flex-basis: 100%;
  }
}
</style>
