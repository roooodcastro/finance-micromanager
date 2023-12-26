<template>
  <InfoAlert
    v-if="reconciliation.id"
    :message="t('message', { date: formatDate(reconciliation.date), href: reconciliationPath })"
    html
  />
</template>

<script>
import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';
import { reconciliations as reconciliationsApi } from '~/api/all.js';

import InfoAlert from '~/components/bootstrap/InfoAlert.vue';

export default {
  components: {
    InfoAlert,
  },

  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.reconciliations.info_alert');

    const reconciliationPath = reconciliationsApi.show.path({ id: props.reconciliation?.id });

    return {
      t,
      formatDate,
      reconciliationPath,
    };
  },
};
</script>
