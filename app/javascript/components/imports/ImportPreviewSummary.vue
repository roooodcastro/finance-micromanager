<template>
  <div class="row">
    <div class="col-12 col-xxl-5 mb-3 mb-xxl-0">
      <LoadingOverlay :loading="loadingImportTransactions">
        <BCard
          :title="t('summary_title')"
          full-height
        >
          <dl class="row mb-0">
            <DescriptionListItem :title="t('target_wallet_label')">
              {{ importObject.wallet.name }}
            </DescriptionListItem>
            <DescriptionListItem :title="t('date_range_label')">
              {{ `${formatDate(minDateFound)} - ${formatDate(maxDateFound)}` }}
            </DescriptionListItem>
            <DescriptionListItem :title="t('total_count_label')">
              {{ transactionCount }}
            </DescriptionListItem>
            <DescriptionListItem :title="t('valid_count_label')">
              {{ validTransactionCount }}
            </DescriptionListItem>
          </dl>
        </BCard>
      </LoadingOverlay>
    </div>

    <div class="col-12 col-xxl-7">
      <BCard
        :title="t('stats_title')"
        full-height
      >
        <div class="row ImportPreviewSummary__statisticsRow">
          <div
            v-for="actionStats in actionsStatsData"
            :key="actionStats.id"
            class="col-6 col-md-3"
          >
            <LoadingOverlay :loading="loadingImportTransactions">
              <div :class="`card bg-${actionStats.variant}-subtle text-${actionStats.variant}-emphasis border-0`">
                <div class="card-body">
                  <h5 class="card-title fs-6">
                    <FontAwesomeIcon :icon="actionStats.icon" />
                    {{ actionStats.label }}
                  </h5>

                  <span class="fs-1">
                    {{ actionStats.count }}
                  </span>
                </div>
              </div>
            </LoadingOverlay>
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

import I18n from '~/utils/I18n.js';
import useImportTransactionStore from '~/stores/ImportTransactionStore.js';
import { formatDate } from '~/utils/DateUtils.js';
import { IMPORT_ACTIONS, VARIANTS_FOR_IMPORT_ACTIONS, IMPORT_ACTION_BLOCK } from '~/utils/Constants.js';

import BCard from '~/components/bootstrap/BCard.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';
import DescriptionListItem from '~/components/layout/DescriptionListItem.vue';

export default {
  components: {
    BCard,
    DescriptionListItem,
    FontAwesomeIcon,
    LoadingOverlay,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.summary');

    const importTransactionStore = useImportTransactionStore();
    const { importTransactions, loading: loadingImportTransactions } = storeToRefs(importTransactionStore);

    const transactionCount = computed(() => importTransactions.value.length);
    const validTransactionCount = computed(() => {
      return importTransactions.value.filter(transaction => transaction.action !== IMPORT_ACTION_BLOCK).length
    });
    const minDateFound = computed(() => {
      return _.minBy(importTransactions.value, transaction => transaction.transactionDate)?.transactionDate
    });
    const maxDateFound = computed(() => {
      return _.maxBy(importTransactions.value, transaction => transaction.transactionDate)?.transactionDate
    });

    const actionsStatsData = computed(() => {
      return IMPORT_ACTIONS.map((importActionData) => {
        return {
          id: importActionData.id,
          count: importTransactions.value.filter(transaction => transaction.action === importActionData.id).length,
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
      loadingImportTransactions,
      formatDate,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .ImportPreviewSummary__statisticsRow > :nth-child(1) {
    margin-bottom: 1rem;
  }
}
</style>
