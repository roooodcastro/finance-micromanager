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
      <div
        class="d-flex align-items-center py-2 ps-2"
        :class="{ 'fst-italic bg-danger-subtle': isDisabled, 'bg-light-subtle': !isDisabled }"
      >
        <span>
          {{ subcategory.name }}
          <template v-if="isDisabled">
            ({{ t('disabled') }})
          </template>
        </span>

        <div class="d-none d-lg-flex ms-auto pe-2 flex-shrink-0">
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

    return {
      t,
      isDisabled,
    };
  }
};
</script>

<style lang="scss" scoped>
.SubcategoryListItem:first-child {
  border-top: none !important;
}
</style>
