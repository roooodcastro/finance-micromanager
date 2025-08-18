<template>
  <button
    class="HelpButton btn btn-outline-info btn-sm rounded-circle d-flex align-items-center justify-content-center border-0"
    @click="$emit('click')"
  >
    <FontAwesomeIcon :icon="['far', 'circle-question']" />
  </button>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  emits: ['click'],
};

</script>

<style lang="scss" scoped>
.HelpButton {
  aspect-ratio: 1;
  height: 2.5rem;
  width: auto;

  svg {
    font-size: 1.5rem;
  }
}
</style>
