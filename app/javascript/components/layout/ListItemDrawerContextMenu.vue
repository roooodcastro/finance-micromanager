<template>
  <div class="position-relative">
    <div
      ref="actionsContainer"
      class="ListItemDrawerContextMenu__actions position-absolute d-flex d-lg-none"
    >
      <slot name="actions" />
    </div>

    <HorizontalSwipe
      :min-translation="minTranslation"
      :max-translation="0"
    >
      <slot name="item" />
    </HorizontalSwipe>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted } from 'vue';

import { isMediaBreakpointUp } from '~/utils/ResponsivenessUtils.js';

import HorizontalSwipe from '~/components/layout/HorizontalSwipe.vue';

export default {
  components: {
    HorizontalSwipe
  },
  setup() {
    const minTranslation = ref(0);
    const actionsContainer = ref(null);

    const setMinTranslation = () => {
      if (isMediaBreakpointUp('lg')) {
        minTranslation.value = 0;
      } else {
        minTranslation.value = -actionsContainer.value.clientWidth;
      }
    };

    onMounted(() => {
      window.addEventListener('resize', setMinTranslation);

      setMinTranslation();
    });

    onUnmounted(() => window.removeEventListener('resize', setMinTranslation));

    return {
      minTranslation,
      actionsContainer,
    };
  }
};
</script>

<style lang="scss">
.ListItemDrawerContextMenu__actions {
  right: 0;
  top: 0;
  bottom: 0;

  a {
    width: 4rem;
  }
}
</style>
