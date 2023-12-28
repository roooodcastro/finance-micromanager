<template>
  <span
    :class="`badge rounded-pill text-bg-${variant}`"
  >
    {{ statusName }}
  </span>
</template>
<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import { VARIANTS_FOR_RECONCILIATION_STATUSES } from '~/utils/Constants.js';

export default {
  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const statusName = computed(() => {
      return I18n.t(`activerecord.attributes.reconciliation.statuses.${props.reconciliation.status}`);
    });
    const variant = computed(() => VARIANTS_FOR_RECONCILIATION_STATUSES[props.reconciliation.status]);

    return {
      statusName,
      variant,
    }
  },
};
</script>
