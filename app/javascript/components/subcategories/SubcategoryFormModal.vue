<template>
  <div
    id="subcategoryFormModal"
    class="modal fade"
    tabindex="-1"
    :aria-labelledby="title"
    aria-hidden="true"
  >
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ title }}
          </h5>
          <CloseButton dismiss="modal" />
        </div>
        <div
          v-if="subcategory"
          class="modal-body"
        >
          <SubcategoryForm
            :category="category"
            :subcategory="subcategory"
          />
        </div>
        <div class="SubcategoryFormModal__footer d-grid d-lg-flex gap-2 modal-footer">
          <button
            type="button"
            class="btn btn-outline-secondary"
            data-bs-dismiss="modal"
          >
            <FontAwesomeIcon
              :icon="['far', 'circle-xmark']"
              class="me-2"
            />

            {{ t('cancel') }}
          </button>
          <button
            type="submit"
            form="subcategoryForm"
            class="btn btn-primary"
          >
            <FontAwesomeIcon
              icon="floppy-disk"
              class="me-lg-2"
            />

            {{ t('submit') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n';
import useCategoryStore from '~/stores/CategoryStore.js';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';

import CloseButton from '~/components/bootstrap/CloseButton.vue';
import SubcategoryForm from '~/components/subcategories/SubcategoryForm.vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    CloseButton,
    FontAwesomeIcon,
    SubcategoryForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.subcategories.form');

    const categoryStore = useCategoryStore();
    const subcategoryStore = useSubcategoryStore();

    const { category } = storeToRefs(categoryStore);
    const { subcategoryForFormModal: subcategory } = storeToRefs(subcategoryStore);

    const isNewSubcategory = computed(() => !subcategory.value?.id);
    const title = computed(() => {
      return isNewSubcategory.value ? t('new_title') : t('edit_title', { name: subcategory.value.name });
    });

    return {
      t,
      category,
      subcategory,
      title,
    }
  },
};
</script>

<style lang="scss" scoped>
.SubcategoryFormModal__footer {
  grid-template-columns: repeat(2, 1fr);
}
</style>
