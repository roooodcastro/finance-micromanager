<template>
  <div :class="{ 'LoadingOverlay': loading, 'LoadingOverlay__minHeight': loading && showLoadingMessage }">
    <slot v-if="!loading || !showLoadingMessage" />

    <div class="LoadingOverlay__loadingIndicator d-flex align-items-center gap-3">
      <FontAwesomeIcon
        v-if="loading"
        icon="spinner"
        spin
      />

      <span
        v-if="loading && showLoadingMessage"
        class="fs-5"
        v-html="t('loading_message')"
      />
    </div>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';

export default {
  components: { FontAwesomeIcon },

  props: {
    loading: {
      type: Boolean,
      default: false,
    },

    showLoadingMessage: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    return { t: I18n.scopedTranslator('views.layout.rails') };
  }
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
  left: 50%;
  font-size: 3rem;
  top: 50%;
  transform: translate(-50%, -50%);
}

.LoadingOverlay__minHeight {
  height: 10rem;
}
</style>
