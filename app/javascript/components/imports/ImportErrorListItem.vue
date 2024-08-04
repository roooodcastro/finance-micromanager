<template>
  <ListItem
    :record="errorTransaction.importTransaction"
  >
    <div class="d-flex flex-column min-width-0 p-2">
      <span class="d-flex align-items-center gap-2">
        <span>
          {{ errorTransaction.importTransaction.originalImportName }}
        </span>
        <FontAwesomeIcon
          icon="ellipsis-vertical"
          class="text-secondary mx-3"
        />
        <span>
          {{ formatDate(errorTransaction.importTransaction.transactionDate) }}
        </span>
        <FontAwesomeIcon
          icon="ellipsis-vertical"
          class="text-secondary mx-3"
        />
        <span>
          {{ formatMoney(errorTransaction.importTransaction.amount) }}
        </span>
      </span>
      <span class="fs-6 text-muted text-truncate">
        {{ t('reason_label') }}:
        {{ t(errorTransaction.reasonI18nKey, errorTransaction.i18nAttributes) }}
      </span>
    </div>
  </ListItem>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { formatDate } from '~/utils/DateUtils.js';

import ListItem from '~/components/ui/ListItem.vue';

export default {
  components: {
    FontAwesomeIcon,
    ListItem,
  },

  props: {
    errorTransaction: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.errors');

    return {
      t,
      formatMoney,
      formatDate,
    };
  }
};
</script>
