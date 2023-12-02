<template>
  <div class="vr mx-3 d-none d-lg-flex"></div>

  <EditButton
    small
    href="#"
    data-bs-toggle="modal"
    data-bs-target="#subcategoryFormModal"
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

<script>
import useSubcategoryStore from '~/stores/SubcategoryStore.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
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
    const subcategoryStore = useSubcategoryStore();

    const handleEdit = () => subcategoryStore.setSubcategoryIdForFormModal(props.subcategory.id);
    const handleDelete = () => subcategoryStore.disable(props.category.id, props.subcategory.id);

    return {
      handleEdit,
      handleDelete,
    };
  },
};
</script>
