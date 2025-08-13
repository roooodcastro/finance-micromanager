<template>
  <component
    :is="noCard ? 'div' : 'BCard'"
    no-body
  >
    <h4 class="card-title mx-3 mt-3 mb-5 d-none d-md-block">
      {{ t('sub_header_summary') }}
    </h4>

    <LoadingOverlay
      :loading="loading"
      class="CategorySummary__card-body m-3"
    >
      <div class="row">
        <div class="col-6">
          <h6 class="m-0">
            {{ t('money_in') }}
          </h6>
          <span class="fs-3 fw-bold text-credit">
            {{ category.summary.creditAmount }}
          </span>
        </div>

        <div class="col-6 text-end">
          <h6 class="m-0">
            {{ t('expenses') }}
          </h6>
          <span class="fs-3 fw-bold text-debit">
            {{ category.summary.debitAmount }}
          </span>
        </div>
      </div>
    </LoadingOverlay>
  </component>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

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
    noCard: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.categories.show');

    return {
      t,
      formatMoney,
    };
  },
};
</script>

<style lang="scss" scoped>
.CategorySummary__card-body-subtitle {
  margin: 1rem 0 2rem -0.5rem ;
}
</style>
