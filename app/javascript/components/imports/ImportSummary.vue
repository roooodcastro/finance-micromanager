<template>
  <BCard
    :title="t('summary_title')"
  >
    <dl class="row mb-0">
      <DescriptionListItem :title="t('file_name_label')">
        {{ importObject.fileName }}
      </DescriptionListItem>
      <DescriptionListItem :title="t('target_wallet_label')">
        {{ importObject.wallet.name }}
      </DescriptionListItem>
      <DescriptionListItem :title="t('total_count_label')">
        {{ transactionCount }}
      </DescriptionListItem>
    </dl>
  </BCard>
</template>

<script>
import _ from 'lodash';

import I18n from '~/utils/I18n.js';
import { formatDate } from '~/utils/DateUtils.js';

import BCard from '~/components/bootstrap/BCard.vue';
import DescriptionListItem from '~/components/layout/DescriptionListItem.vue';

export default {
  components: {
    BCard,
    DescriptionListItem,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
    transactionCount: {
      type: Number,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.summary');

    return {
      t,
      formatDate,
    };
  },
};
</script>
