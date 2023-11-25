<template>
  <ListItemDrawerContextMenu class="mx-2 mx-lg-0">
    <template v-slot:actions>
      <CategoryActions
        :category="category"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div class="CategoryListItem d-flex bg-light-subtle align-items-center border bg-white p-2">
        <span
          class="CategoriesList__color-indicator rounded-circle me-3"
          :style="{ backgroundColor: category.color }"
        />
        <span>{{ category.name }}</span>

        <div class="d-none d-lg-flex">
          <CategoryActions :category="category" />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import CategoryActions from '~/components/categories/CategoryActions.vue';
import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';

export default {
  components: {
    CategoryActions,
    ListItemDrawerContextMenu,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.CategoryListItem:not(:first-child) {
  margin-top: -1px;
}

.CategoriesList__color-indicator {
  border: 1px solid $table-border-color;
  display: inline-block;
  width: 2em;
  height: 2em;
}
</style>
