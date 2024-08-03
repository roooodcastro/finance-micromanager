<template>
  <HorizontalSwipe
    id="verticalMenu"
    class="VerticalMenuOffCanvas offcanvas offcanvas-start overflow-y-hidden"
    aria-labelledby="mainMenuLabel"
    :min-translation="minTranslation"
    :max-translation="0"
    :enabled="swipeActive"
    v-on="{ 'hide.bs.offcanvas': handleHide, 'shown.bs.offcanvas': handleShown }"
    @swipeleft="handleSwipeClose"
  >
    <VerticalMenu
      offcanvas
      class="offcanvas-body px-0 pt-0 d-flex flex-column"
    />
  </HorizontalSwipe>
</template>

<script>
import { onMounted, ref } from 'vue';
import { Offcanvas as BootstrapOffcanvas } from 'bootstrap';

import HorizontalSwipe from '~/components/layout/HorizontalSwipe.vue';
import VerticalMenu from '~/components/layout/VerticalMenu.vue';

export default {
  components: {
    HorizontalSwipe,
    VerticalMenu,
  },

  setup() {
    const offcanvas = ref(null);

    onMounted(() => {
      const offcanvasElement = document.querySelector('#verticalMenu');
      offcanvas.value = new BootstrapOffcanvas(offcanvasElement);
    });

    const minTranslation = ref(0);

    const setMinTranslation = () => {
      minTranslation.value = -document.querySelector('#verticalMenu').clientWidth;
    };

    onMounted(() => setMinTranslation());

    // Disable HorizontalSwipe so that Bootstrap's OffCanvas transition works
    const swipeActive = ref(false);
    const handleShown = () => swipeActive.value = true;
    const handleHide = () => swipeActive.value = false;

    const handleSwipeClose = () => {
      offcanvas.value.hide();

      // Trick to force the HorizontalSwipe to reset the transition value
      minTranslation.value = 0;
      setTimeout(setMinTranslation, 0);
    };

    return {
      minTranslation,
      swipeActive,
      handleShown,
      handleHide,
      handleSwipeClose,
    };
  },
}
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .VerticalMenuOffCanvas {
    max-width: 80vw;
  }
}
</style>
