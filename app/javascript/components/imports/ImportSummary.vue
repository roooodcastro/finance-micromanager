<template>
  <BCard
    :title="t('summary_title')"
  >
    <dl class="row mb-0">
      <dt class="col-6 col-md-4 my-1">
        {{ t('file_name_label') }}
      </dt>
      <dd class="col-6 col-md-8 my-1">
        {{ importObject.fileName }}
      </dd>
      <dt class="col-6 col-md-4 my-1">
        {{ t('target_wallet_label') }}
      </dt>
      <dd class="col-6 col-md-8 my-1">
        {{ importObject.wallet.name }}
      </dd>
      <dt class="col-6 col-md-4 my-1">
        {{ t('date_range_label') }}
      </dt>
      <dd class="col-6 col-md-8 my-1">
        {{ `${formatDate(minDateFound)} - ${formatDate(maxDateFound)}` }}
      </dd>
      <dt class="col-6 col-md-4 my-1">
        {{ t('total_count_label') }}
      </dt>
      <dd class="col-6 col-md-8 my-1">
        {{ transactionCount }}
      </dd>
    </dl>
  </BCard>
</template>

<script>
import { computed } from 'vue';
import _ from 'lodash';

import BCard from '~/components/bootstrap/BCard.vue';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';

export default {
  components: {
    BCard,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
    importedTransactions: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.summary');

    const transactionCount = computed(() => props.importedTransactions.length);
    const minDateFound = computed(() => {
      return _.minBy(props.importedTransactions, transaction => transaction.transactionDate)?.transactionDate
    });
    const maxDateFound = computed(() => {
      return _.maxBy(props.importedTransactions, transaction => transaction.transactionDate)?.transactionDate
    });

    return {
      t,
      transactionCount,
      minDateFound,
      maxDateFound,
      formatDate,
    };
  },
};
</script>
