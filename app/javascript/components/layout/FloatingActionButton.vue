<template>
  <div class="FloatingActionButton position-sticky end-0 bottom-0 py-3">
    <div
      class="FloatingActionButton__speed-dial"
      :class="{ show: speedDialOpened }"
    >
      <a
        v-for="(speedDialEntry, index) in speedDialEntries"
        :key="index"
        href="#"
        class="FloatingActionButton__speed-dial-link d-flex rounded-pill btn btn-light shadow mb-3"
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
      class="FloatingActionButton__link d-flex btn btn-primary rounded-circle fs-1 shadow ms-auto"
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
      callback();
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
  z-index: 1;
  margin: auto 0 -1rem auto;
}

.FloatingActionButton__link {
  align-items: center;
  justify-content: center;
  width: 4rem;
  height: 4rem;

  &::before {
    border-radius: 50% 0 0 0;
    cursor: default;
    content: '';
    position: fixed;
    background-color: rgba($modal-backdrop-bg, $modal-backdrop-opacity);
    width: 0;
    height: 0;
    z-index: -1;
    transition: all 0.15s ease-in-out;
    bottom: 0;
    right: 0;
  }

  &.active::before {
    border-radius: 0;
    width: 100vw;
    height: 100vh;
  }

  svg {
    transform: rotate(0);
    transition: all 0.15s ease-in-out;
  }

  svg.rotated {
    transform: rotate(135deg);
  }
}

.FloatingActionButton__speed-dial {
  white-space: nowrap;
  position: absolute;
  right: 1rem;
  bottom: 5rem;
  overflow: hidden;
  transform: scaleY(0);

  &.show {
    transform: scaleY(1);
  }

  .FloatingActionButton__speed-dial-link {
    align-items: center;
    justify-content: end;
    line-height: 3rem;
    position: relative;
    height: 3rem;
    transition: all 0.15s ease-out;
  }

  &.show .FloatingActionButton__speed-dial-link {
    bottom: 0 !important;
  }
}
</style>
