<template>
  <ListItem
    :record="{ category, subcategory }"
    :actions-component="SubcategoryActions"
    card-body
  >
    <div class="d-flex justify-content-between flex-grow-1 p-2 pe-0">
      <div :class="{ 'text-muted': isDisabled }">
        {{ subcategory.name }}

        <span
          v-if="isDisabled"
          class="badge text-bg-danger"
        >
          {{ t('disabled') }}
        </span>
      </div>

      <span
        class="text-end fw-bold"
        :class="{
          'text-muted': isDisabled,
          'text-credit': subcategorySummary.balanceAmount > 0 && !isDisabled,
          'text-debit': subcategorySummary.balanceAmount < 0 && !isDisabled
        }"
      >
        {{ formatMoney(subcategorySummary.balanceAmount ?? 0) }}
      </span>
    </div>
  </ListItem>
</template>

<script>
import { computed, markRaw } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { fixUuidObjectKeys } from '~/utils/StringUtils.js';

import SubcategoryActions from '~/components/subcategories/SubcategoryActions.vue';
import ListItem from '~/components/ui/ListItem.vue';

export default {
  components: { ListItem },

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
    markRaw(SubcategoryActions);
    const t = I18n.scopedTranslator('views.subcategories.list');
    const isDisabled = computed(() => !!props.subcategory.disabledAt);

    const subcategorySummary = computed(() => {
      return fixUuidObjectKeys(props.category.subcategoriesSummary)[props.subcategory.id] ?? {};
    });

    return {
      t,
      isDisabled,
      subcategorySummary,
      formatMoney,
      SubcategoryActions,
    };
  }
};
</script>
