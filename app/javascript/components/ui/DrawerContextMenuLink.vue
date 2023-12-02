<template>
  <a
    v-bind="$attrs"
    :aria-label="label"
    :class="cssClasses"
  >
    <FontAwesomeIcon
      :icon="icon"
      size="lg"
    />
    <span class="d-none d-lg-inline-block ms-2">
      {{ label }}
    </span>
  </a>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    icon: {
      type: [String, Array],
      required: true,
    },
    label: {
      type: String,
      required: true,
    },
    drawer: {
      type: Boolean,
      default: false,
    },
    variant: {
      type: String,
      default: 'primary',
    },
  },

  setup(props) {
    const drawerCssClasses = `d-flex align-items-center justify-content-center bg-${props.variant} text-white`;
    const nonDrawerCssClasses = `text-${props.variant}`;

    const cssClasses = {};
    cssClasses[drawerCssClasses] = props.drawer;
    cssClasses[nonDrawerCssClasses] = !props.drawer;

    return {
      cssClasses,
    };
  },
};
</script>
