<template>
  <ListItemDrawerContextMenu class="list-group-item overflow-hidden p-0">
    <template v-slot:actions>
      <component
        :is="actionsComponent"
        v-if="actionsComponent"
        :record="record"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div :class="`ListItem d-flex justify-content-between align-items-center ${itemContainerClass}`">
        <slot />

        <div class="d-none d-lg-flex ms-auto pe-2 flex-shrink-0">
          <component
            :is="actionsComponent"
            v-if="actionsComponent"
            :record="record"
          />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';

export default {
  components: {
    ListItemDrawerContextMenu,
  },

  props: {
    actionsComponent: {
      type: Object,
      default: null,
    },
    record: {
      type: Object,
      required: true,
    },
    itemContainerClass: {
      type: String,
      default: 'bg-white',
    },
  },
};
</script>

<style lang="scss" scoped>
.ListItem:not(:first-child) {
  margin-top: -1px;
}

.ListItem__card-body:first-child {
  border-top: none !important;
}

.ListItem__card-body:last-child {
  border-bottom: none !important;
}
</style>
