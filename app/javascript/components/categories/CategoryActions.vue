<template>
  <div class="vr mx-3 d-none d-lg-flex"></div>

  <EditButton
    small
    :href="editCategoryPath(category.id)"
    :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
  />

  <DeleteButton
    small
    href="#"
    :class="{
      'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
      'ms-3': !drawerMenu,
    }"
    @delete="handleDelete(category.id)"
  />
</template>

<script>
import I18n from '~/utils/I18n';
import { categories as categoriesApi } from '~/api';
import useCategoryStore from '~/stores/CategoryStore';
import useNotificationStore from '~/stores/NotificationStore';

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
    drawerMenu: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const editCategoryPath = (categoryId) => categoriesApi.edit.path({ id: categoryId });

    const categoryStore = useCategoryStore();
    const notificationStore = useNotificationStore();

    const handleDelete = (id) => {
      categoriesApi.destroy({ id }).then((response) => {
        notificationStore.notify(response.message, 'success');
        categoryStore.remove(response.categoryId);
      });
    };

    return {
      t: I18n.scopedTranslator('views.categories.index'),
      editCategoryPath,
      handleDelete,
    };
  },
};
</script>
