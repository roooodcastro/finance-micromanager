<template>
  <div class="position-relative">
    <div
      id="ListItemDrawerContextMenu__actions"
      class="ListItemDrawerContextMenu__actions position-absolute d-flex d-lg-none"
      @click="handleActionClick"
    >
      <slot name="actions" />
    </div>

    <div
      class="ListItemDrawerContextMenu"
      :style=" { transform: `translateX(${translation}px)` }"
      @touchstart="handleTouchStart"
      @touchmove="handleTouchMove"
      @touchend="handleTouchEnd"
    >
      <slot name="item" />
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted } from 'vue';

import { isMediaBreakpointUp } from '~/utils/ResponsivenessUtils.js';

export default {
  setup() {
    const startPosX = ref(0);

    const minTranslation = 0;
    const maxTranslation = ref(0);
    const translation = ref(0);

    const setMaxTranslation = () => {
      if (isMediaBreakpointUp('lg')) {
        maxTranslation.value = 0;
        translation.value = 0;
      } else {
        const actionsContainer = document.querySelector('#ListItemDrawerContextMenu__actions');
        maxTranslation.value = -actionsContainer.clientWidth;
      }
    };

    onMounted(() => {
      window.addEventListener('resize', setMaxTranslation);

      setMaxTranslation();
    });

    onUnmounted(() => {
      window.removeEventListener('resize', setMaxTranslation);
    });

    const touchX = event => event.touches[0].clientX;

    const handleTouchStart = ev => startPosX.value = touchX(ev) - translation.value;

    const handleTouchMove = (ev) => {
      const currentX = touchX(ev);
      translation.value = Math.max(maxTranslation.value, Math.min(currentX - startPosX.value, minTranslation));
    };

    const handleTouchEnd = () => {
      if (translation.value < maxTranslation.value / 2) {
        translation.value = maxTranslation.value;
      } else {
        translation.value = minTranslation;
      }
    };

    const handleActionClick = () => translation.value = 0;

    return {
      handleTouchStart,
      handleTouchMove,
      handleTouchEnd,
      handleActionClick,
      translation,
    };
  }
};
</script>

<style lang="scss">
.ListItemDrawerContextMenu {
  transition: all 0.1s linear;
}

.ListItemDrawerContextMenu__actions {
  right: 0;
  top: 0;
  bottom: 0;

  a {
    width: 4rem;
  }
}
</style>
