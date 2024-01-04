<template>
  <template v-if="!category.system">
    <div class="vr mx-3 d-none d-lg-flex" />

    <EditButton
      small
      href="#"
      :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
      @click="handleEdit"
    />

    <DeleteButton
      small
      href="#"
      disable-label
      :class="{
        'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
        'ms-3': !drawerMenu,
      }"
      @delete="handleDelete"
    />
  </template>
</template>

<script>
import I18n from '~/utils/I18n.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
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

    const handleEdit = () => categoryStore.openFormModal(props.category.id);
    const handleDelete = () => categoryStore.disable(props.category.id);

    return {
      t: I18n.scopedTranslator('views.categories.index'),
      handleEdit,
      handleDelete,
    };
  },
};
</script>
