<template>
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
            :href="destroyCategoryPath(category.id)"
            class="ms-2"
          />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { watch, toRef } from 'vue';
import { storeToRefs } from 'pinia';

import { categories as categoriesApi } from '~/api';
import I18n from '~/utils/I18n';
import useAccountStore from '~/stores/AccountStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
    DeleteButton,
    EditButton,
  },

  props: {
    categories: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const editCategoryPath = (categoryId) => categoriesApi.edit.path({ id: categoryId });
    const destroyCategoryPath = (categoryId) => categoriesApi.destroy.path({ id: categoryId });

    // Load categories from props
    const categoryStore = useCategoryStore();
    const { categories: categoriesFromStore } = storeToRefs(categoryStore);
    categoriesFromStore.value = toRef(props.categories);

    // Reload categories if account has changed while this page is open
    const accountStore = useAccountStore();
    watch(
      () => accountStore.currentAccount,
      () => {
        categoriesApi.list().then(response => categoriesFromStore.value = response.categories);
      },
    );

    return {
      editCategoryPath,
      destroyCategoryPath,
      t: I18n.scopedTranslator('views.categories.index'),
      categoriesFromStore,
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
