<template>
  <ListItemDrawerContextMenu class="SubcategoryListItem list-group-item border-0 border-top p-0">
    <template v-slot:actions>
      <SubcategoryActions
        :category="category"
        :subcategory="subcategory"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div class="d-flex align-items-center py-2 ps-2 bg-light-subtle">
        <div class="d-flex justify-content-between flex-grow-1">
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

        <div class="d-none d-lg-flex ms-auto flex-shrink-0">
          <SubcategoryActions
            :category="category"
            :subcategory="subcategory"
          />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { fixUuidObjectKeys } from '~/utils/StringUtils.js';

import SubcategoryActions from '~/components/subcategories/SubcategoryActions.vue';
import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';

export default {
  components: {
    ListItemDrawerContextMenu,
    SubcategoryActions,
  },

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
    };
  }
};
</script>

<style lang="scss" scoped>
.SubcategoryListItem:first-child {
  border-top: none !important;
}
</style>
