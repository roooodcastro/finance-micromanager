<template>
  <header
    v-if="title || $slots.default"
    class="d-flex align-items-center justify-content-between mt-2 mt-lg-4 flex-wrap"
    v-bind="$attrs"
  >
    <h1
      v-if="title || $slots.default"
      class="PageHeader__h1 d-flex align-items-center mb-0 mb-lg-2"
    >
      <a
        v-if="backButtonHref"
        :href="backButtonHref"
        class="btn btn-outline-secondary btn-sm me-3"
      >
        <FontAwesomeIcon icon="chevron-left" />
      </a>

      <span class="d-flex flex-column">
        <span v-if="title">
          {{ title }}
        </span>
        <slot v-else />

        <template v-if="subTitle">
          <span class="fs-4 text-muted d-block">
            {{ subTitle }}
          </span>
        </template>
      </span>
    </h1>

    <slot name="actions" />
  </header>

  <hr />
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

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
    backButtonHref: {
      type: String,
      default: null,
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
