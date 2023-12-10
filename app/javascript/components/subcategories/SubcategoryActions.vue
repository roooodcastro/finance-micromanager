<template>
  <div class="vr mx-3 d-none d-lg-flex" />

  <template v-if="isDisabled">
    <DrawerContextMenuLink
      variant="success"
      icon="repeat"
      href="#"
      :label="t('reenable_label')"
      :drawer="drawerMenu"
      :class="{ 'SubcategoryActions__reenable-button': !drawerMenu }"
      @click="handleReenable"
    />
  </template>
  <template v-else>
    <EditButton
      small
      href="#"
      :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
      @click="handleEdit"
    />

    <DeleteButton
      small
      disable-label
      href="#"
      :class="{
        'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
        'ms-3': !drawerMenu,
      }"
      @delete="handleDelete"
    />
  </template>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';
import DrawerContextMenuLink from '~/components/ui/DrawerContextMenuLink.vue';

export default {
  components: {
    DrawerContextMenuLink,
    DeleteButton,
    EditButton
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
    drawerMenu: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.subcategories.list');
    const subcategoryStore = useSubcategoryStore();

    const isDisabled = computed(() => !!props.subcategory.disabledAt);

    const handleEdit = () => subcategoryStore.openFormModal(props.subcategory.id);
    const handleDelete = () => subcategoryStore.disable(props.category.id, props.subcategory.id);
    const handleReenable = () => subcategoryStore.reenable(props.subcategory.id);

    return {
      t,
      handleEdit,
      handleDelete,
      handleReenable,
      isDisabled,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.SubcategoryActions__reenable-button {
  background-color: $light-bg-subtle;
  margin: -0.5rem -0.5rem -0.5rem -1rem;
  padding: 0.5rem 0.5rem 0.5rem 1rem;
}
</style>
