<template>
  <div class="row">
    <div class="col col-lg-6">
      <BCard
        :title="t('summary_title')"
      >
        <dl class="row mb-0">
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
          <dt class="col-6 col-md-4 my-1">
            {{ t('valid_count_label') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            {{ validTransactionCount }}
          </dd>
        </dl>
      </BCard>
    </div>
    <div class="col col-lg-6">
      <BCard
        :title="t('stats_title')"
      >
        <div class="row">
          <div
            v-for="actionStats in actionsStatsData"
            :key="actionStats.id"
            class="col col-md-6 col-lg-3"
          >
            <div :class="`card bg-${actionStats.variant}-subtle text-${actionStats.variant}-emphasis border-0`">
              <div class="card-body">
                <h5 class="card-title">
                  <FontAwesomeIcon :icon="actionStats.icon" />
                  {{ actionStats.label }}
                </h5>

                <span class="fs-1">
                  {{ actionStats.count }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </BCard>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import _ from 'lodash';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import BCard from '~/components/bootstrap/BCard.vue';

import I18n from '~/utils/I18n.js';
import useImportStore from '~/stores/ImportStore.js';
import { formatDate } from '~/utils/DateUtils.js';
import { IMPORT_ACTIONS, VARIANTS_FOR_IMPORT_ACTIONS, IMPORT_ACTION_BLOCK } from '~/utils/Constants.js';

export default {
  components: {
    BCard,
    FontAwesomeIcon,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.summary');

    const importStore = useImportStore();
    const { previewData } = storeToRefs(importStore);

    const transactionCount = computed(() => previewData.value.length);
    const validTransactionCount = computed(() => {
      return previewData.value.filter(transaction => transaction.actionId !== IMPORT_ACTION_BLOCK).length
    });
    const minDateFound = computed(() => {
      return _.minBy(previewData.value, transaction => transaction.transactionDate)?.transactionDate
    });
    const maxDateFound = computed(() => {
      return _.maxBy(previewData.value, transaction => transaction.transactionDate)?.transactionDate
    });

    const actionsStatsData = computed(() => {
      return IMPORT_ACTIONS.map((importActionData) => {
        return {
          id: importActionData.id,
          count: previewData.value.filter(transaction => transaction.actionId === importActionData.id).length,
          icon: importActionData.icon,
          label: t(`stats_${importActionData.id}_label`),
          variant: VARIANTS_FOR_IMPORT_ACTIONS[importActionData.id],
        }
      });
    });

    return {
      t,
      transactionCount,
      validTransactionCount,
      actionsStatsData,
      minDateFound,
      maxDateFound,
      formatDate,
    };
  },
};
</script>
