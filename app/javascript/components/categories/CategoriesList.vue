<template>
  <div>
    <Pagination
      :pagination="paginationFromStore"
      class="mb-3"
      @change="handlePageChange"
    />

    <table class="table align-middle bg-white">
      <thead class="table-light">
        <tr>
          <th>{{ t('name') }}</th>
          <th>{{ t('color') }}</th>
          <th></th>
        </tr>
      </thead>
      <tbody class="table-group-divider">
        <tr
          v-for="category in categoriesFromStore"
          :key="category.id"
        >
          <td>{{ category.name }}</td>
          <td>
            <div class="d-flex align-items-center">
              <span
                class="CategoriesList__color-indicator me-3"
                :style="{ backgroundColor: category.color }"
              />
              <span>{{ category.color }}</span>
            </div>
          </td>
          <td class="text-end">
            <EditButton
              small
              :href="editCategoryPath(category.id)"
            />

            <DeleteButton
              small
              href="#"
              class="ms-2"
              @delete="handleDelete(category.id)"
            />
          </td>
        </tr>
      </tbody>
    </table>

    <Pagination
      :pagination="paginationFromStore"
      class="mt-3"
      @change="handlePageChange"
    />
  </div>
</template>

<script>
import { watch, toRef } from 'vue';
import { storeToRefs } from 'pinia';

import { categories as categoriesApi } from '~/api';
import I18n from '~/utils/I18n';
import useWalletStore from '~/stores/WalletStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';
import Pagination from "~/components/rails/Pagination.vue";

export default {
  components: {
    Pagination,
    DeleteButton,
    EditButton,
  },

  props: {
    categories: {
      type: Array,
      required: true,
    },
    pagination: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const editCategoryPath = (categoryId) => categoriesApi.edit.path({ id: categoryId });

    const categoryStore = useCategoryStore();
    const notificationStore = useNotificationStore();

    // Load categories from props
    const {
      categories: categoriesFromStore,
      pagination: paginationFromStore,
    } = storeToRefs(categoryStore);

    categoriesFromStore.value = toRef(props.categories);
    paginationFromStore.value = toRef(props.pagination).value;

    // Reload categories if wallet has changed while this page is open
    const walletStore = useWalletStore();
    watch(
      () => walletStore.currentWallet,
      () => {
        categoriesApi.index().then(response => categoriesFromStore.value = response.categories);
      },
    );

    const handlePageChange = (page) => categoryStore.changePage(page);
    const handleDelete = (id) => {
      categoriesApi.destroy({ id }).then((response) => {
        notificationStore.notify(response.message, 'success');
        categoryStore.remove(response.categoryId);
      });
    };

    return {
      editCategoryPath,
      handlePageChange,
      t: I18n.scopedTranslator('views.categories.index'),
      categoriesFromStore,
      paginationFromStore,
      handleDelete,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.CategoriesList__color-indicator {
  border: 1px solid $table-border-color;
  display: inline-block;
  width: 2em;
  height: 2em;
}
</style>
