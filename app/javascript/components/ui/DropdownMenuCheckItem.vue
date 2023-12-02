<template>
  <a
    class="dropdown-item py-2 ps-3"
    :href="href"
  >
    <FontAwesomeIcon
      v-if="checked"
      icon="check"
    />
    <span
      v-else
      class="px-2"
    />
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
