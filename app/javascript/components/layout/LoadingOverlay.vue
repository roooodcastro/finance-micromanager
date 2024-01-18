<template>
  <div :class="{ 'LoadingOverlay': loading }">
    <slot />

    <div class="LoadingOverlay__loadingIndicator">
      <FontAwesomeIcon
        v-if="loading"
        icon="spinner"
        spin
      />
    </div>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: { FontAwesomeIcon },
  props: {
    loading: {
      type: Boolean,
      default: false,
    },
  },
};
</script>

<style lang="scss" scoped>
.LoadingOverlay {
  position: relative;

  &::after {
    content: '';
    position: absolute;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.2);
    z-index: 1
  }
}

.LoadingOverlay__loadingIndicator {
  position: absolute;
  left: calc(50% - 1.5rem);
  font-size: 3rem;
  top: calc(50% - 1.5rem);
}
</style>
