<template>
  <template v-if="!isCategoryDisabled">
    <div class="vr mx-3 d-none d-lg-flex" />

    <template v-if="isDisabled">
      <DrawerContextMenuLink
        variant="success"
        icon="repeat"
        href="#"
        label=""
        :drawer="drawerMenu"
        :class="{ 'SubcategoryActions__reenable-button me-0': !drawerMenu }"
        @click="handleReenable"
      />
    </template>
    <template v-else>
      <EditButton
        small
        compact
        href="#"
        :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
        @click="handleEdit"
      />

      <div class="vr mx-3 d-none d-lg-flex" />

      <DeleteButton
        small
        disable-label
        compact
        href="#"
        :class="{
          'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
          'me-0 me-lg-3': !drawerMenu,
        }"
        ask-confirmation
        @delete="handleDelete"
      />
    </template>
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
    record: {
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

    const category = props.record.category;
    const subcategory = props.record.subcategory;

    const isCategoryDisabled = computed(() => !!category.disabledAt);
    const isDisabled = computed(() => !!subcategory.disabledAt);

    const handleEdit = () => subcategoryStore.openFormModal(subcategory.id);
    const handleDelete = () => subcategoryStore.disable(category.id, subcategory.id);
    const handleReenable = () => subcategoryStore.reenable(subcategory.id);

    return {
      t,
      category,
      subcategory,
      handleEdit,
      handleDelete,
      handleReenable,
      isDisabled,
      isCategoryDisabled,
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
