<template>
  <div
    class="HorizontalSwipe"
    :style="swipeStyle"
    @touchstart="handleTouchStart"
    @touchmove="handleTouchMove"
    @touchend="handleTouchEnd"
  >
    <slot />
  </div>
</template>

<script>
import { watch, ref } from 'vue';

import { clamp } from '~/utils/NumberUtils.js';

export default {
  props: {
    minTranslation: {
      type: Number,
      default: 0,
    },
    maxTranslation: {
      type: Number,
      default: 0,
    },
    enabled: {
      type: Boolean,
      default: true,
    },
  },

  emits: ['swipeleft', 'swiperight'],

  setup(props, { emit }) {
    const startPosX = ref(0);
    const translation = ref(0);
    const swipeStyle = ref({});

    watch(props, () => updateTranslation(clamp(translation.value, props.minTranslation, props.maxTranslation)));

    const updateTranslation = (newTranslation) => {
      translation.value = newTranslation;
      swipeStyle.value = props.enabled ? { transform: `translateX(${translation.value}px)` } : {};
    };

    updateTranslation(translation.value);

    const touchX = (event) => event.touches[0].clientX;

    const handleTouchStart = (ev) => startPosX.value = touchX(ev) - translation.value;

    const handleTouchMove = (ev) => {
      const currentX = touchX(ev);
      updateTranslation(clamp(currentX - startPosX.value, props.minTranslation, props.maxTranslation));
    }

    const handleTouchEnd = () => {
      const midTranslation = (props.minTranslation + props.maxTranslation) / 2;

      if (translation.value < midTranslation) {
        updateTranslation(props.minTranslation);
        emit('swipeleft');
      } else {
        updateTranslation(props.maxTranslation);
        emit('swiperight');
      }
    };

    return {
      handleTouchStart,
      handleTouchMove,
      handleTouchEnd,
      translation,
      swipeStyle,
    };
  },
};
</script>

<style lang="scss" scoped>
.HorizontalSwipe {
  transition: all 0.1s linear;
}
</style>
