<template>
  <template v-if="!category.system">
    <div class="vr mx-3 d-none d-lg-flex" />

    <EditButton
      v-if="!isDisabled"
      small
      href="#"
      :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
      @click="handleEdit"
    />

    <DeleteButton
      v-if="!isDisabled"
      small
      href="#"
      disable-label
      :class="{
        'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
        'ms-3': !drawerMenu,
      }"
      @delete="handleDelete"
    />

    <DrawerContextMenuLink
      v-if="isDisabled"
      variant="success"
      icon="repeat"
      href="#"
      :label="t('reenable_label')"
      :drawer="drawerMenu"
      :class="{ 'CategoryActions__reenable-button': !drawerMenu }"
      @click="handleReenable"
    />
  </template>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';

import useCategoryStore from '~/stores/CategoryStore.js';
import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';
import DrawerContextMenuLink from '~/components/ui/DrawerContextMenuLink.vue';

export default {
  components: {
    DrawerContextMenuLink,
    DeleteButton,
    EditButton,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
    drawerMenu: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const categoryStore = useCategoryStore();

    const isDisabled = computed(() => !!props.category.disabledAt);

    const handleEdit = () => categoryStore.openFormModal(props.category.id);
    const handleDelete = () => categoryStore.disable(props.category.id);
    const handleReenable = () => categoryStore.reenable(props.category.id);

    return {
      t: I18n.scopedTranslator('views.categories.index'),
      isDisabled,
      handleEdit,
      handleDelete,
      handleReenable,
    };
  },
};
</script>
