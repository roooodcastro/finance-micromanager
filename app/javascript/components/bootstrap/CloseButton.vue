<template>
  <button
    type="button"
    class="btn-close"
    :data-bs-dismiss="dismiss"
    :aria-label="t('close')"
  />
</template>

<script>
import I18n from '~/utils/I18n.Js';

export default {
  props: {
    dismiss: {
      type: String,
      default: 'alert',
    },
  },

  setup() {
    return {
      t: I18n.scopedTranslator('views.layout.rails'),
    };
  },
};
</script>
