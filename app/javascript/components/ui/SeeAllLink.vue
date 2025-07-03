<template>
  <a class="fs-6">
    {{ t('label') }}
  </a>
</template>

<script>
import I18n from '~/utils/I18n.js';

export default {
  setup() {
    const t = I18n.scopedTranslator('views.components.see_all_link');

    return { t };
  }
}
</script>
