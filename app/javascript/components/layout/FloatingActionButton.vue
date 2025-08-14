<template>
  <div class="FloatingActionButton">
    <div
      class="FloatingActionButton__speed-dial"
      :class="{ show: speedDialOpened }"
    >
      <a
        v-for="(speedDialEntry, index) in speedDialEntries"
        :key="index"
        :href="speedDialEntry.href ?? '#'"
        class="FloatingActionButton__speed-dial-link d-flex rounded-pill btn btn-light mb-3"
        :style="{ bottom: `${(speedDialEntries.length - index) * -4}rem` }"
        @click="handleSpeedDialClick(speedDialEntry.callback)"
      >
        <span class="me-3">
          {{ speedDialEntry.label }}
        </span>

        <FontAwesomeIcon :icon="speedDialEntry.icon" />
      </a>
    </div>

    <a
      class="FloatingActionButton__link d-flex btn btn-primary rounded-circle fs-1"
      :class="{ active: speedDialOpened }"
      href="#"
      @click="handleClick"
    >
      <FontAwesomeIcon
        icon="plus"
        :class="{ rotated: speedDialOpened }"
      />
    </a>
  </div>
</template>

<script>
import { computed, ref } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const floatingActionButtonStore = useFloatingActionButtonStore();
    const { speedDialEntries } = storeToRefs(floatingActionButtonStore);

    const speedDialShouldOpen = computed(() => speedDialEntries.value.length > 1);
    const speedDialOpened = ref(false);

    const handleClick = () => {
      if (speedDialShouldOpen.value) {
        speedDialOpened.value = !speedDialOpened.value;
      } else {
        speedDialEntries.value[0].callback();
      }
    };

    const handleSpeedDialClick = (callback) => {
      speedDialOpened.value = false;
      if (callback) {
        callback();
      }
    }

    return {
      speedDialShouldOpen,
      speedDialOpened,
      speedDialEntries,
      handleClick,
      handleSpeedDialClick,
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.FloatingActionButton {
  position: absolute;
  top: calc((min(18vw, $navigation-tabs-height + 1rem) - 100%) / -2);
  z-index: 1;
}

.FloatingActionButton__link {
  align-items: center;
  aspect-ratio: 1;
  box-shadow: 0 0rem 0.5rem rgba($black, .15);
  justify-content: center;
  max-width: calc($navigation-tabs-height + 1rem);
  width: 18vw;

  &::before {
    border-radius: 50%;
    cursor: default;
    content: '';
    position: fixed;
    background-color: rgba($modal-backdrop-bg, $modal-backdrop-opacity);
    width: 0;
    height: 0;
    z-index: -1;
    transition: all 0.2s ease-in-out;
    bottom: 1rem;
    right: 50%;
  }

  &.active::before {
    right: -25%;
    bottom: -25%;
    width: 150vw;
    height: 150vh;
  }

  svg {
    transform: rotate(0);
    transition: all 0.2s ease-in-out;
  }

  svg.rotated {
    transform: rotate(135deg);
  }
}

.FloatingActionButton__speed-dial {
  white-space: nowrap;
  position: fixed;
  right: 50%;
  bottom: 6rem;
  overflow: hidden;
  transform: translate(50%, 50%) scaleY(0);
  transition: all 0.2s ease-in-out;

  &.show {
    transform: translate(50%, 0) scaleY(1);
  }

  .FloatingActionButton__speed-dial-link {
    align-items: center;
    justify-content: end;
    line-height: 3rem;
    position: relative;
    height: 3rem;
    transition: all 0.2s ease-in-out;
  }

  &.show .FloatingActionButton__speed-dial-link {
    bottom: 0 !important;
  }
}

@include media-breakpoint-up(lg) {
  .FloatingActionButton {
    margin: auto 0 -6rem auto;
    right: 0;
    bottom: 1rem;
    left: initial;
    position: sticky;
    padding-right: 1rem;
  }

  .FloatingActionButton__link {
    top: initial;
    margin-left: auto;
    width: 4rem;

    &::before {
      border-radius: 50%;
      bottom: 2rem;
      right: 3rem;
    }
  }

  .FloatingActionButton__speed-dial {
    position: absolute;
    right: 1rem;
    overflow: hidden;
    transform: translateY(50%) scaleY(0);

    &.show {
      transform: translateY(0) scaleY(1);
    }
  }
}
</style>
