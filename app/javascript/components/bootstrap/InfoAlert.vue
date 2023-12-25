<template>
  <div
    class="alert alert-info"
    :class="{ 'd-lg-flex align-items-center': !compact }"
  >
    <FontAwesomeIcon
      icon="circle-info"
      class="InfoAlert__icon me-2"
      :class="{ 'align-self-center me-lg-3': !compact }"
    />

    <div
      class="d-inline"
      :class="{ 'd-lg-block': !compact }"
    >
      <strong v-if="title">
        {{ title }}:
      </strong>

      {{ message }}
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
    }
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .InfoAlert__icon {
    font-size: 1em;
    margin-right: 0.75em;
  }
}

@include media-breakpoint-up(lg) {
  .InfoAlert__icon {
    font-size: 2em;
  }
}
</style>
