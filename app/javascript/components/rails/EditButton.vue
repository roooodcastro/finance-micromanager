<template>
  <a
    v-bind="$attrs"
    class="btn btn-outline-secondary"
    :class="{ 'btn-sm': small }"
  >
    <FontAwesomeIcon
      icon="pen-to-square"
      size="lg"
    />
    <span class="d-none d-lg-inline-block ms-2">
      {{ t('edit') }}
    </span>
  </a>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import I18n from '@/utils/I18n';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    small: {
      type: Boolean,
      default: false,
    }
  },

  setup() {
    return {
      t: I18n.scopedTranslator('views.layout.rails'),
    };
  },
};
</script>
