<template>
  <a
    v-bind="$attrs"
    class="text-secondary"
  >
    <FontAwesomeIcon
      icon="pen-to-square"
      size="lg"
    />
    <span
      v-if="!compact"
      class="d-none d-lg-inline-block ms-2"
    >
      {{ t('edit') }}
    </span>
  </a>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import I18n from '~/utils/I18n.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    compact: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    return {
      t: I18n.scopedTranslator('views.layout.rails'),
    };
  },
};
</script>
