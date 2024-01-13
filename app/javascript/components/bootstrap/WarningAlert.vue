<template>
  <div
    class="alert alert-warning"
    :class="{ 'd-lg-flex align-items-center': !compact }"
  >
    <FontAwesomeIcon
      icon="triangle-exclamation"
      class="WarningAlert__icon me-2"
      :class="{ 'align-self-center me-lg-3': !compact }"
    />

    <div
      class="d-inline"
      :class="{ 'd-lg-block': !compact }"
    >
      <strong v-if="title">
        {{ title }}:
      </strong>

      <span
        v-if="html"
        v-html="message"
      />
      <template v-else>
        {{ message }}
      </template>
    </div>
  </div>
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
    message: {
      type: String,
      required: true,
    },
    compact: {
      type: Boolean,
      default: false,
    },
    html: {
      type: Boolean,
      default: false,
    },
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .WarningAlert__icon {
    font-size: 1em;
    margin-right: 0.75em;
  }
}

@include media-breakpoint-up(lg) {
  .WarningAlert__icon {
    font-size: 2em;
  }
}
</style>
