<template>
  <component
    :is="noCard ? 'div' : 'BCard'"
    no-body
  >
    <div class="d-flex justify-content-between align-items-center mx-3 mt-4 mt-md-3 mb-3">
      <h4 class="m-0">
        {{ t('sub_header_subcategories') }}
      </h4>

      <DropdownMenu
        v-if="!isCategoryDisabled"
        toggle-icon="gear"
        :toggle-label="t('subcategories_options')"
      >
        <DropdownMenuItem
          :label="t('new_subcategory')"
          icon="plus"
          @click="handleNewSubcategory"
        />

        <hr class="my-2">

        <DropdownMenuCheckItem
          :label="t('show_all_subcategories')"
          :checked="showDisabled"
          @click="handleShowDisabledSubcategories"
        />
      </DropdownMenu>
    </div>

    <SubcategoriesList v-if="subcategories.length" />

    <div
      v-else
      class="text-center py-3"
    >
      <a
        href="#"
        class="btn btn-sm btn-outline-primary"
        @click="handleNewSubcategory"
      >
        <FontAwesomeIcon
          icon="plus"
          class="me-2"
        />

        {{ t('new_subcategory') }}
      </a>
    </div>
  </component>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useSubcategoryStore from '~/stores/SubcategoryStore.js';

import BCard from '~/components/bootstrap/BCard.vue';
import DropdownMenu from '~/components/ui/DropdownMenu.vue';
import DropdownMenuCheckItem from '~/components/ui/DropdownMenuCheckItem.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import SubcategoriesList from '~/components/subcategories/SubcategoriesList.vue';

export default {
  components: {
    BCard,
    DropdownMenu,
    DropdownMenuCheckItem,
    DropdownMenuItem,
    FontAwesomeIcon,
    SubcategoriesList,
  },

  props: {
    noCard: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const t = I18n.scopedTranslator('views.categories.show');

    const categoryStore = useCategoryStore();
    const subcategoryStore = useSubcategoryStore();

    const { category } = storeToRefs(categoryStore);
    const { subcategories, showDisabled } = storeToRefs(subcategoryStore);

    const isCategoryDisabled = computed(() => !!category.value.disabledAt);

    const handleNewSubcategory = () => subcategoryStore.openFormModal(null);
    const handleShowDisabledSubcategories = () => subcategoryStore.setShowDisabled(!showDisabled.value);

    return {
      t,
      isCategoryDisabled,
      subcategories,
      showDisabled,
      handleNewSubcategory,
      handleShowDisabledSubcategories,
    };
  },
};
</script>
