<template>
  <span class="badge text-bg-danger">
    {{ I18n.t('views.layout.rails.disabled') }}
  </span>
</template>

<script>
import I18n from '~/utils/I18n.js';

export default {
  setup() {
    return { I18n };
  },
};
</script>
