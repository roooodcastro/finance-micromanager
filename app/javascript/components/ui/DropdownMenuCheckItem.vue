<template>
  <a
    class="dropdown-item py-2 ps-3"
    :href="href"
  >
    <FontAwesomeIcon :icon="checked ? 'square-check' : ['far', 'square']" />
    <span class="ms-2">{{ label }}</span>
  </a>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: { FontAwesomeIcon },

  props: {
    label: {
      type: String,
      required: true,
    },
    href: {
      type: String,
      default: '#',
    },
    checked: {
      type: Boolean,
      default: false,
    },
  },
};
</script>
