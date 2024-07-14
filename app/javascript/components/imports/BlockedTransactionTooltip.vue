<template>
  <a
    ref="tooltip"
    href="#"
    class="btn btn-context-action rounded-circle me-2"
    data-bs-toggle="tooltip"
    data-bs-placement="right"
    :data-bs-title="message"
    @mouseover="initializeTooltip"
  >
    <FontAwesomeIcon
      :icon="['far', 'circle-question']"
      size="lg"
    />
  </a>
</template>

<script>
import { ref } from 'vue';
import { Tooltip as BootstrapTooltip } from 'bootstrap';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: { FontAwesomeIcon },
  props: {
    message: {
      type: String,
      required: true,
    },
  },
  setup() {
    const tooltip = ref(null);
    const tooltipInitialized = ref(false);

    const initializeTooltip = () => {
      if (!tooltipInitialized.value) {
        new BootstrapTooltip(tooltip.value);
        tooltipInitialized.value = true;
      }
    }

    return {
      tooltip,
      initializeTooltip,
    };
  },
};
</script>
