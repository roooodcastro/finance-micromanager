<template>
  <div
    class="d-flex mt-3 align-items-center justify-content-center sticky-bottom bg-white p-3 gap-3 shadow"
  >
    <button
      type="submit"
      class="btn btn-primary"
    >
      <FontAwesomeIcon icon="cloud-arrow-up" />
      {{ t('submit_button') }}
    </button>

    <a
      href="#"
      class="btn btn-outline-secondary"
    >
      <FontAwesomeIcon icon="ban" />
      {{ t('cancel_button') }}
    </a>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.preview');

    return { t };
  },
};
</script>
