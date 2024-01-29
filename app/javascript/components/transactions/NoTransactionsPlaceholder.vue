<template>
  <div class="text-center mt-3 text-muted border rounded p-3">
    {{ t('no_transactions') }}
    <FontAwesomeIcon :icon="['far', 'face-frown']" />
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    return {
      t: I18n.scopedTranslator('views.transactions.index'),
    };
  },
};
</script>
