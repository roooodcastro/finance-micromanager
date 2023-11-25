<template>
  <div class="position-relative">
    <div
      id="ListItemDrawerContextMenu__actions"
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

    const setMinTranslation = () => {
      if (isMediaBreakpointUp('lg')) {
        minTranslation.value = 0;
      } else {
        const actionsContainer = document.querySelector('#ListItemDrawerContextMenu__actions');
        minTranslation.value = -actionsContainer.clientWidth;
      }
    };

    onMounted(() => {
      window.addEventListener('resize', setMinTranslation);

      setMinTranslation();
    });

    onUnmounted(() => window.removeEventListener('resize', setMinTranslation));

    return {
      minTranslation,
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
