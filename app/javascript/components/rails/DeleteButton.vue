<template>
  <a
    v-bind="$attrs"
    class="text-danger"
    data-method="DELETE"
    :data-confirm="disableLabel ? t('disable_confirmation') : t('delete_confirmation')"
  >
    <FontAwesomeIcon
      :icon="['far', 'square-minus']"
      size="lg"
    />
    <span class="d-none d-lg-inline-block ms-2">
      {{ disableLabel ? t('disable') : t('delete') }}
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
    disableLabel: {
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
