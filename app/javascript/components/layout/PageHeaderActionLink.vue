<template>
  <a class="dropdown-item py-2 ps-3">
    <FontAwesomeIcon
      v-if="icon"
      :icon="icon"
    />
    <span class="ms-2">{{ label }}</span>
  </a>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: { FontAwesomeIcon },

  props: {
    icon: {
      type: [String, Array],
      default: null,
    },
    label: {
      type: String,
      required: true,
    },
  },
};
</script>
