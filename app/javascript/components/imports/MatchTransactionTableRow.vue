<template>
  <div
    class="GridRow__left"
    :class="{ selected: match.selected }"
  >
    <div
      class="d-flex gap-2 align-items-center"
      :class="{ 'ms-4': match.selected }"
    >
      <span>
        {{ match.transaction.name }}
      </span>
      <StarsSlider
        :value="match.matchScore"
        :max="3"
      />
    </div>

    <div :class="{ 'ms-4': match.selected }">
      {{ match.transaction.subcategory?.displayName ?? match.transaction.category.name }}
    </div>
  </div>

  <div
    class="GridRow__right"
    :class="{ selected: match.selected }"
  >
    <div>
      {{ formatMoney(match.transaction.amount) }}
    </div>

    <div>
      {{ formatDate(match.transaction.transactionDate) }}
    </div>
  </div>

  <FontAwesomeIcon
    v-if="match.selected"
    :icon="['far', 'circle-check']"
    size="xl"
    class="text-primary MatchTransactionTableRow__selectedCheckIcon"
  />
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { formatDate } from '~/utils/DateUtils.js';

import StarsSlider from '~/components/ui/StarsSlider.vue';

export default {
  components: {
    FontAwesomeIcon,
    StarsSlider,
  },

  props: {
    match: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.categories_list');

    return {
      t,
      formatMoney,
      formatDate,
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.GridRow__left.selected, .GridRow__right.selected {
  border: 1px solid $primary;
}

.GridRow__left.selected {
  border-right: none;
}

.GridRow__right.selected {
  border-left: none;
}

.MatchTransactionTableRow__selectedCheckIcon {
  left: 1rem;
  position: absolute;
  top: 50%;
  transform: translate(0, -50%);
}
</style>
