<template>
  <div class="dropdown">
    <a
      href="#"
      class="btn btn-context-action rounded-circle"
      :class="toggleClass"
      data-bs-toggle="dropdown"
      aria-expanded="false"
      :aria-label="toggleLabel"
    >
      <FontAwesomeIcon :icon="toggleIcon" />
    </a>
    <div class="dropdown-menu">
      <slot />
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
    toggleLabel: {
      type: String,
      required: true,
    },
    toggleIcon: {
      type: [String, Array],
      required: true,
    },
    toggleClass: {
      type: String,
      default: '',
    },
  },
};
</script>
