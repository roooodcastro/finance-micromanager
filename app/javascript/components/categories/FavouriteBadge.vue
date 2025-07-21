<template>
  <span class="badge border border-warning text-warning d-flex gap-3 align-items-center">
    <FontAwesomeIcon icon="star" />
    {{ I18n.t('views.categories.show.favourite') }}
  </span>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';

export default {
  components: {FontAwesomeIcon },

  setup() {
    return { I18n };
  },
};
</script>
