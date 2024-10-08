<template>
  <BCard :title="t('sub_header_summary')">
    <LoadingOverlay
      :loading="loading"
      class="CategorySummary__card-body p-2"
    >
      <div class="row">
        <div class="col-6">
          <h5 class="m-0">
            {{ t('money_in') }}
          </h5>
          <span class="fs-3 fw-bold text-credit">
            {{ category.summary.creditAmount }}
          </span>
        </div>

        <div class="col-6">
          <h5 class="m-0">
            {{ t('expenses') }}
          </h5>
          <span class="fs-3 fw-bold text-debit">
            {{ category.summary.debitAmount }}
          </span>
        </div>
      </div>
    </LoadingOverlay>
  </BCard>
</template>

<script>
import I18n from '~/utils/I18n.js';

import BCard from '~/components/bootstrap/BCard.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';

export default {
  components: {
    BCard,
    LoadingOverlay,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
    loading: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    return { t: I18n.scopedTranslator('views.categories.show') };
  },
};
</script>
