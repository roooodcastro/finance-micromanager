<template>
  <dt class="DescriptionListItem__term col-12 col-sm-6 col-md-4 pt-2 pt-sm-1 pb-0 pb-sm-1 my-0">
    <FontAwesomeIcon
      v-if="icon"
      :icon="icon"
      class="me-2"
    />
    {{ title }}
  </dt>
  <dd
    class="DescriptionListItem__details col-12 col-sm-6 col-md-8 pb-2 pb-sm-1 pt-0 pt-sm-1 my-0"
    :class="detailsClass"
  >
    <slot />
  </dd>
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
      required: true,
    },
    icon: {
      type: [String, Array],
      default: null,
    },
    detailsClass: {
      type: [String, Object],
      default: null,
    },
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(sm) {
  .DescriptionListItem__term:has(+ .DescriptionListItem__details) {
    border-top: var(--bs-border-width) solid var(--bs-border-color);
  }

  .DescriptionListItem__details {
    border-bottom: var(--bs-border-width) solid var(--bs-border-color);
  }

  .DescriptionListItem__details:has(+ .DescriptionListItem__term) {
    border-bottom: none;
  }
}
</style>
