<template>
  <div class="dropdown">
    <a
      href="#"
      class="btn btn-context-action rounded-circle gap-5"
      :class="toggleClass"
      data-bs-toggle="dropdown"
      aria-expanded="false"
      :aria-label="toggleLabel"
    >
      <FontAwesomeIcon :icon="toggleIcon" />
      <span v-if="!!title">
        {{ title }}
      </span>
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
    title: {
      type: String,
      default: '',
    },
  },
};
</script>
