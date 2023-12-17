<template>
  <div class="card">
    <div class="card-header">
      <h5 class="m-0">
        {{ t('sub_header_summary') }}
      </h5>
    </div>
    <div class="ReconciliationSummary__card-body card-body d-grid gap-2 p-2">
      <div class="card bg-primary-subtle border-0">
        <div class="card-body">
          <h5 class="card-title">
            {{ t('status') }}
          </h5>

          <span class="fs-2">
            {{ I18n.t(`activerecord.attributes.reconciliation.statuses.${reconciliation.status}`) }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

export default {
  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
  },

  setup() {
    return {
      t: I18n.scopedTranslator('views.reconciliations.show'),
      I18n,
    };
  },
};
</script>

<style lang="scss" scoped>
.ReconciliationSummary__card-body {
  grid-template-columns: repeat(2, minmax(0, 1fr));
  grid-auto-flow: column;
}
</style>
