<template>
  <Badge
    :variant="variant"
    :i18n-scope="statusName"
  />
</template>
<script>
import { computed } from 'vue';

import { VARIANTS_FOR_RECONCILIATION_STATUSES } from '~/utils/Constants.js';

import Badge from '~/components/ui/Badge.vue';

export default {
  components: { Badge },

  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const statusName = computed(() => {
      return `activerecord.attributes.reconciliation.statuses.${props.reconciliation.status}`;
    });
    const variant = computed(() => VARIANTS_FOR_RECONCILIATION_STATUSES[props.reconciliation.status]);

    return {
      statusName,
      variant,
    }
  },
};
</script>
