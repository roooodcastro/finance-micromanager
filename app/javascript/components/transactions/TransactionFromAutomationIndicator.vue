<template>
  <FontAwesomeIcon
    ref="iconElement"
    icon="robot"
    data-bs-toggle="tooltip"
    :data-bs-title="t('transaction_from_automation_tooltip')"
  />
</template>

<script>
import { onMounted, ref } from 'vue';
import { Tooltip as BootstrapTooltip } from 'bootstrap';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.transactions.index');
    const iconElement = ref(null);

    onMounted(() => {
      new BootstrapTooltip(iconElement.value.$el);
    });

    return {
      t,
      iconElement,
    };
  },
};
</script>

<style lang="scss" scoped>
.InfoTooltip__span {
  width: 1.2em;
  height: 1.2em;
}
</style>
