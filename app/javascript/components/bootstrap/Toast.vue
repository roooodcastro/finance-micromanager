<template>
  <div
    ref="rootDiv"
    :class="`toast bg-${variant}`"
    role="alert"
    aria-live="polite"
    aria-atomic="true"
  >
    <div class="toast-header">
      <FontAwesomeIcon
        class="me-2"
        :icon="icon"
      />
      {{ t(`toast_title_${variant}`) }}

      <CloseButton
        class="ms-auto"
        dismiss="toast"
      />
    </div>
    <div class="toast-body">
      {{ message }}
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import I18n from '~/utils/I18n.js';

import CloseButton from '~/components/bootstrap/CloseButton.vue';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { Toast as BootstrapToast } from 'bootstrap';

export default {
  components: {
    CloseButton,
    FontAwesomeIcon,
  },

  props: {
    variant: {
      type: String,
      default: 'info',
    },
    message: {
      type: String,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.layout.rails');

    const rootDiv = ref(null);
    const toast = ref(null);

    const faIcons = {
      'success': ['far', 'circle-check'],
      'info': 'circle-info',
      'warning': 'triangle-exclamation',
      'danger': ['far', 'circle-xmark'],
    }

    const icon = faIcons[props.variant];

    onMounted(() => {
      toast.value = new BootstrapToast(rootDiv.value);
      toast.value.show();
    });

    return {
      t,
      icon,
      rootDiv,
    };
  },
}
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.toast {
  &.bg-success {
    .toast-header {
      background-color: var(--toast-success-header-bg-color);
    }
    .toast-body {
      background-color: var(--toast-success-header-body-color);
    }
  }
  &.bg-info {
    .toast-header {
      background-color: var(--toast-info-header-bg-color);
    }
    .toast-body {
      background-color: var(--toast-info-header-body-color);
    }
  }
  &.bg-warning {
    .toast-header {
      background-color: var(--toast-warning-header-bg-color);
    }
    .toast-body {
      background-color: var(--toast-warning-header-body-color);
    }
  }
  &.bg-danger {
    .toast-header {
      background-color: var(--toast-danger-header-bg-color);
    }
    .toast-body {
      background-color: var(--toast-danger-header-body-color);
    }
  }
}
</style>
