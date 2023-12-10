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
import I18n from '~/utils/I18n.Js';

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
      background-color: $mintgreen-400;
    }
    .toast-body {
      background-color: $mintgreen-200;
    }
  }
  &.bg-info {
    .toast-header {
      background-color: $cyan-400;
    }
    .toast-body {
      background-color: $cyan-200;
    }
  }
  &.bg-warning {
    .toast-header {
      background-color: $yellow-400;
    }
    .toast-body {
      background-color: $yellow-200;
    }
  }
  &.bg-danger {
    .toast-header {
      background-color: $red-400;
    }
    .toast-body {
      background-color: $red-200;
    }
  }
}
</style>
