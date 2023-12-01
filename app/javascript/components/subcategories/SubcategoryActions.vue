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
    href="#"
    :class="{
      'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
      'ms-3': !drawerMenu,
    }"
    @delete="handleDelete(subcategory.id)"
  />
</template>

<script>
import { subcategories as subcategoriesApi } from '~/api';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
    DeleteButton,
    EditButton
  },

  props: {
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
    const notificationStore = useNotificationStore();

    const handleEdit = () => subcategoryStore.setSubcategoryIdForFormModal(props.subcategory.id);

    const handleDelete = (id) => {
      subcategoriesApi.destroy({ id }).then((response) => {
        notificationStore.notify(response.message, 'success');
        // subcategoryStore.remove(response.subcategoryId);
      });
    };

    return {
      handleEdit,
      handleDelete,
    };
  },
};
</script>
