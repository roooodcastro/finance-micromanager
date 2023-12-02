<template>
  <ListItemDrawerContextMenu class="SubcategoryListItem list-group-item border-0 border-top p-0">
    <template v-slot:actions>
      <SubcategoryActions
        :subcategory="subcategory"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div class="d-flex bg-light-subtle align-items-center bg-white py-2 ps-2">
        <span>{{ subcategory.name }}</span>

        <div class="d-none d-lg-flex ms-auto pe-2 flex-shrink-0">
          <SubcategoryActions :subcategory="subcategory" />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import SubcategoryActions from '~/components/subcategories/SubcategoryActions.vue';
import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';

export default {
  components: {
    ListItemDrawerContextMenu,
    SubcategoryActions,
  },

  props: {
    subcategory: {
      type: Object,
      required: true,
    },
  },

  setup() {
  }
};
</script>

<style lang="scss" scoped>
.SubcategoryListItem:first-child {
  border-top: none !important;
}
</style>
