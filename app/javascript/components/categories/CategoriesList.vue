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
        v-for="category in categories"
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
        <td>
          <a
            :href="editCategoryPath(category.id)"
            class="btn btn-outline-secondary btn-sm"
          >
            {{ t('edit') }}
          </a>

          <a
            :href="destroyCategoryPath(category.id)"
            data-method="DELETE"
            :data-confirm="t('delete_confirmation')"
            class="btn btn-outline-danger btn-sm ms-2"
          >
            {{ t('delete') }}
          </a>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { categories } from '~/api';
import I18n from '~/utils/I18n';

export default {
  props: {
    categories: {
      type: Array,
      required: true,
    },
  },

  setup() {
    const editCategoryPath = (categoryId) => categories.edit.path({ id: categoryId });
    const destroyCategoryPath = (categoryId) => categories.destroy.path({ id: categoryId });

    return {
      editCategoryPath,
      destroyCategoryPath,
      t: I18n.scopedTranslator('views.categories.index'),
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
