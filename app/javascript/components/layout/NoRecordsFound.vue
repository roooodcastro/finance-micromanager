<template>
  <div class="d-flex justify-content-center align-items-center text-muted gap-2 border rounded p-3">
    {{ t('no_records') }}
    <FontAwesomeIcon
      :icon="['far', 'face-frown']"
      size="lg"
    />
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: { FontAwesomeIcon },

  setup() {
    return {
      t: I18n.scopedTranslator('views.layout.rails'),
    };
  },
};
</script>
