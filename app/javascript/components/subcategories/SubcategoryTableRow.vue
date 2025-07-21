<template>
  <div class="GridRow__left">
    <div class="d-flex gap-2 align-items-center">
      <span>{{ subcategory.name }}</span>

      <Badge
        v-if="isDisabled"
        type="disabled"
        i18n-scope="views.categories.show.disabled"
      />
    </div>
  </div>

  <div class="GridRow__right">
    <div
      class="text-end fw-bold"
      :class="{
        'text-muted': isDisabled,
        'text-credit': subcategorySummary.balanceAmount > 0 && !isDisabled,
        'text-debit': subcategorySummary.balanceAmount < 0 && !isDisabled
      }"
    >
      {{ formatMoney(subcategorySummary.balanceAmount ?? 0) }}
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';

import { formatMoney } from '~/utils/NumberFormatter.js';
import { fixUuidObjectKeys } from '~/utils/StringUtils.js';

import Badge from '~/components/ui/Badge.vue';

export default {
  components: { Badge },

  props: {
    category: {
      type: Object,
      required: true,
    },
    subcategory: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const isDisabled = computed(() => !!props.subcategory.disabledAt);

    const subcategorySummary = computed(() => {
      return fixUuidObjectKeys(props.category.subcategoriesSummary)[props.subcategory.id] ?? {};
    });

    return {
      isDisabled,
      subcategorySummary,
      formatMoney,
    };
  }
};
</script>
